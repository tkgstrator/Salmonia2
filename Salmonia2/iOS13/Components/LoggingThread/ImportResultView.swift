//
//  ImportResultView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import RealmSwift
import Alamofire
import SwiftyJSON
import SplatNet2

struct ImportResultView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @State var log = Log()

    var body: some View {
        LoggingThread(log: $log)
            .onAppear() {
                do {
                    guard let realm = try? Realm() else { return }
                    guard let user = realm.objects(SalmoniaUserRealm.self).first else { throw APPError.active }
                    let accounts = user.account.filter("isActive=%@", true)
                    let version = user.isVersion
                    
                    // ユーザ名とか取得するためにセッションキーが必要
                    guard let _iksm_session: String = accounts.first?.iksm_session else { throw APPError.active }
                    guard let session_token: String = accounts.first?.session_token else { throw APPError.active }
                    
                    // 二回目以降のインポートを無効化する
                    try? realm.write {
                        realm.objects(SalmoniaUserRealm.self).first?.isImported = true
                    }
                    
                    // ニックネームとか取得に必要なので
                    if !SplatNet2.isValid(iksm_session: _iksm_session) {
                        do {
                            let response = try SplatNet2.genIksmSession(session_token, version: version)
                            let iksm_session = response["iksm_session"].stringValue
                            try? realm.write {
                                accounts.first?.iksm_session = iksm_session
                            }
                        } catch {
                            log.errorDescription = "Unknown error"
                        }
                    }
                    
                    guard let iksm_session: String = accounts.first?.iksm_session else { return }
                    let time: [Int] = Array(Set(realm.objects(CoopResultsRealm.self).map({ $0.play_time })))
                    
                    // 全ユーザに対してリザルト取得（重いぞ）
                    for account in accounts {
                        let nsaid: String = account.nsaid
                        DispatchQueue(label: "Import").async {
                            log.status = "Connecting"
                            #if DEBUG
                            let metadata: (link: Int, job_num: Int) = (5, 1000)
                            #else
                            guard let metadata = try? getLastLink(nsaid: nsaid) else { return }
                            #endif
                            log.progress = (nil, 0, metadata.job_num)
                            DispatchQueue(label: "Pages").async {
                                for page in Range(1 ... metadata.link) {
                                    var nsaids: [String] = []
                                    log.status = "Downloading"
                                    guard let results: JSON = try? getResults(nsaid: nsaid, page: page) else { return }
                                    log.status = "Importing"
                                    autoreleasepool {
                                        guard let realm = try? Realm() else { return }
                                        realm.beginWrite()
                                        for (idx, (_, result)) in results.enumerated() {
                                            // 重複チェックを行う
                                            let start_time: Int = UnixTime.timestampFromDate(date: result["start_at"].stringValue)
                                            if time.filter({ abs($0 - start_time) <= 10 }).isEmpty {
                                                log.progress = (result["id"].intValue, (page - 1) * 200 + idx + 1, metadata.job_num)
                                                realm.create(CoopResultsRealm.self, value: JF.FromSalmonStats(nsaid: nsaid, result), update: .modified)
                                            } else {
                                                log.progress = (result["id"].intValue, (page - 1) * 200 + idx + 1, metadata.job_num)
                                            }
                                            nsaids.append(contentsOf: result["members"].map({ $0.1.stringValue }))
                                             Thread.sleep(forTimeInterval: 0.01)
                                        }
//                                        do {
//                                            let crews: JSON = try SplatNet2.getPlayerNickName(Array(Set(nsaids)), iksm_session: iksm_session)
//                                            for (_, crew) in crews["nickname_and_icons"] {
//                                                let value: [String: Any] = ["nsaid": crew["nsa_id"].stringValue, "name": crew["nickname"].stringValue, "image": crew["thumbnail_url"].stringValue]
//                                                realm.create(CrewInfoRealm.self, value: value, update: .all)
//                                            }
//                                        } catch(let error) {
//                                            log.isValid = false
//                                            log.errorDescription = error.localizedDescription
//                                        }
                                        try? realm.commitWrite()
                                    } // autoreleasepool
//                                    Thread.sleep(forTimeInterval: 5)
                                } // Pages
                            } // DispatchQueue ASync
                        } // DispatchQueue ASync
                    }
                } catch {
                    log.isValid = false
                    log.errorDescription = error.localizedDescription
                }
            }
            .navigationBarTitle("Logging Thread", displayMode: .large)
    }
    

    private func getResults(nsaid: String, page: Int) throws -> JSON {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200&page=\(page)"
        print(url)
        let json = try SAF.request(url)
        return json["results"]
    }
    
    private func getLastLink(nsaid: String) throws -> (link: Int, job_num: Int){
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        let json = try SAF.request(url)
        
        let metadata = json[0]["results"]
        let job_num: Int = metadata["clear"].intValue + metadata["fail"].intValue
        let lastlink = ((metadata["clear"].intValue + metadata["fail"].intValue) / 200) + 1
        return (lastlink, job_num)
    }
    
}

struct ImportResultView_Previews: PreviewProvider {
    static var previews: some View {
        ImportResultView()
    }
}
