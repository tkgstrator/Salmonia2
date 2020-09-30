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

struct ImportResultView: View {
    
    @State var messages: [String] = []
    @State var isLock: Bool = true

    var body: some View {
        LoggingThread(log: $messages, lock: $isLock)
            .onAppear() {
                guard let realm = try? Realm() else { return }
                guard let accounts = realm.objects(SalmoniaUserRealm.self).first?.account else { return }
                let time: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
                
                // ループを抜けるための処理
                let semaphore = DispatchSemaphore(value: 0)
                
                // 全ユーザに対してリザルト取得（重いぞ）
                for account in accounts {
                    let nsaid: String = account.nsaid
                    DispatchQueue(label: "Import").async {
                        guard let lastlink: Int = try? getLastLink(nsaid: nsaid) else { return }
                        DispatchQueue(label: "Pages").async {
                            for page in Range(1 ... 3) {
                                guard let results: JSON = try? getResults(nsaid: nsaid, page: page) else { return }
                                autoreleasepool {
                                    guard let realm = try? Realm() else { return }
                                    realm.beginWrite()
                                    for (idx, (_, result)) in results.enumerated() {
                                        // 重複チェックを行う
                                        let start_time: Int = UnixTime.timestampFromDate(date: result["start_at"].stringValue)
                                        if time.filter({ abs($0 - start_time) <= 10 }).isEmpty {
                                            messages.append("Result: \((page - 1) * 200 + idx + 1) -> \(result["id"].intValue) OK")
                                            realm.create(CoopResultsRealm.self, value: JF.FromSalmonStats(nsaid: nsaid, result), update: .modified)
                                        } else {
                                            messages.append("Result: \((page - 1) * 200 + idx + 1) -> \(result["id"].intValue) NG")
                                        }
                                    }
                                    try? realm.commitWrite()
                                } // autoreleasepool
                                Thread.sleep(forTimeInterval: 5)
                            } // Pages
                        } // DispatchQueue ASync
                    } // DispatchQueue ASync
                    //                    semaphore.signal()
                    print("DONE")
                }
                isLock = false
            }
    }
    private func getResults(nsaid: String, page: Int) throws -> JSON {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200&page=\(page)"
        
        let json = try SAF.request(url)
        return json["results"]
    }
    
    private func getLastLink(nsaid: String) throws -> Int{
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        let json = try SAF.request(url)
        
        let metadata = json[0]["results"]
        let lastlink = ((metadata["clear"].intValue + metadata["fail"].intValue) / 200) + 1
        return lastlink
    }
    
}

struct ImportResultView_Previews: PreviewProvider {
    static var previews: some View {
        ImportResultView()
    }
}
