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
                DispatchQueue(label: "Username").async {
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

                        let players = Array(Set(realm.objects(PlayerResultsRealm.self).map({ $0.nsaid! })))
                        log.progress = (nil, 0, players.count)
                        
                        let _players = players.chunked(by: 400)
                        realm.beginWrite()
                        for _player in _players {
                            log.status = "Downloading"
                            let crews = try SplatNet2.getPlayerNickName(_player, iksm_session: _iksm_session)
                            log.status = "Updating"
                            for (_, crew) in crews["nickname_and_icons"] {
                                let value: [String: Any] = ["nsaid": crew["nsa_id"].stringValue, "name": crew["nickname"].stringValue, "image": crew["thumbnail_url"].stringValue]
                                realm.create(CrewInfoRealm.self, value: value, update: .all)
                                log.progress.min! += 1
                                log.progress.id = crew["nsa_id"].intValue
                                Thread.sleep(forTimeInterval: 0.005)
                            }
                        }
                        try? realm.commitWrite()
                    } catch {
                        
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

