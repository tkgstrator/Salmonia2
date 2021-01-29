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

struct SyncUserData: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @State var log = Log()

    var body: some View {
        LoggingThread(log: $log)
            .onAppear() {
                DispatchQueue.global(qos: .utility).async {
                    do {
                        guard let realm = try? Realm() else { return }
                        guard let account = realm.objects(SalmoniaUserRealm.self).first?.account.first else { throw APPError.active }
                        guard let _iksm_session: String = account.iksm_session else { throw APPError.active }
                        guard let session_token: String = account.session_token else { throw APPError.active }
                        guard let version = realm.objects(SalmoniaUserRealm.self).first?.isVersion else { throw APPError.active }// X-Product Version

                        // iksm_sessionの再生成
                        if !SplatNet2.isValid(iksm_session: _iksm_session) {
                            do {
                                log.status = "Regenerating"
                                let response = try SplatNet2.genIksmSession(session_token, version: version)
                                let iksm_session = response["iksm_session"].stringValue
                                try? realm.write {
                                    account.iksm_session = iksm_session
                                }
                            } catch {
                                log.errorDescription = "Unknown error"
                            }
                        }
                        
                        // マッチングした仲間のnsaidを全て抽出する
                        var players = Array(Set(realm.objects(PlayerResultsRealm.self).map({ $0.nsaid! })))
                        log.progress = (nil, 0, players.count)
                        
                        let _players = players.chunked(by: 200)
                        realm.beginWrite()
                        for (idx, _player) in _players.enumerated() {
                            log.status = "Downloading"
                            let crews = try SplatNet2.getPlayerNickName(_player, iksm_session: _iksm_session)
                            log.status = "Updating"
                            for (id, (_, crew)) in crews["nickname_and_icons"].enumerated() {
                                let value: [String: Any] = ["nsaid": crew["nsa_id"].stringValue, "name": crew["nickname"].stringValue, "image": crew["thumbnail_url"].stringValue]
                                realm.create(CrewInfoRealm.self, value: value, update: .all)
                                if (idx * 200 + id) % 10 == 0 || (idx * 200) + id == players.count {
                                    log.progress.min! = min(log.progress.min! + 10, players.count)
                                    Thread.sleep(forTimeInterval: 0.025)
                                }
                            }
                        }
                        // 全部終わったらアップデートする
                        players = Array(realm.objects(CrewInfoRealm.self).map({ $0.nsaid })) // BANされたアカウント対策
                        for nsaid in players {
                            guard let player = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", nsaid).first else { return }
                            realm.objects(PlayerResultsRealm.self).filter("nsaid=%@", nsaid).setValue(player.name, forKey: "name")
                            
                        }
                        try? realm.commitWrite()
                    } catch {
                        print(error.localizedDescription)
                        
                    }
                }
            }
            .navigationBarTitle("Logging Thread", displayMode: .large)
    }
}

struct ISyncUserData_Previews: PreviewProvider {
    static var previews: some View {
        SyncUserData()
    }
}

