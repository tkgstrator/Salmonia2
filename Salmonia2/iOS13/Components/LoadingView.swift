//
//  LoadingView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import RealmSwift
import Alamofire
import SplatNet2
import SwiftyJSON

struct LoadingView: View {
    
    @State var messages: [String] = []
    @State var isLock: Bool = true
    
    var body: some View {
        LoggingThread(log: $messages, lock: $isLock)
            .onAppear() {
                do {
                    guard let realm = try? Realm() else { throw APIError.Response("2000", "Realm DB Error") }
                    guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
                    guard let api_token = user.api_token else { throw APIError.Response("2001", "Empty API Token") }
                    let version = user.isVersion // X-Product Versionの読み込み

                    let accounts = realm.objects(UserInfoRealm.self).filter("isActive = %@", true)
                    if accounts.count == 0  { throw APIError.Response("2001", "No Active Accounts") }
                    // アクティブなアカウント全てでループ
                    for account in accounts {
                        guard let iksm_session = account.iksm_session else { throw APIError.Response("2001", "Empty Iksm Session") }
                        guard let session_token = account.session_token else { throw APIError.Response("2001", "Empty Session Token") }
                        let nsaid = account.nsaid
                        
                        DispatchQueue(label: "Summary").async {
                            guard let realm = try? Realm() else { return } // 本体のRealmオブジェクト
                            let isValid: Bool = SplatNet2.isValid(iksm_session: iksm_session)
                            if !isValid { // 有効期限が切れていた場合は再生成する
                                do {
                                    guard let user = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid).first else { throw APIError.Response("2003", "No Such Account") }
                                    let response: JSON =  try SplatNet2.genIksmSession(session_token, version: version)
                                    guard let iksm_session = response["iksm_session"].string else { throw APIError.Response("1004", "Iksm Session Error")}
                                    try realm.write { user.setValue(iksm_session, forKey: "iksm_session")}
                                } catch {
                                    // セッションが再生成できなかったときの処理（APIの変更など
                                    print("ACCOUNT \(nsaid) FAILURE")
                                }
                            }
                            // シフトデータを読み込んで書き込む
                            do {
                                realm.beginWrite()
                                guard let iksm_session: String = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid).first?.iksm_session else { return }
                                let summary: JSON = try SplatNet2.getSummary(iksm_session: iksm_session)
                                guard var card: [String: Any] = summary["summary"]["card"].dictionaryObject else { return }
                                card.updateValue(nsaid, forKey: "nsaid")
                                
                                guard let job_num: Int = summary["summary"]["card"]["job_num"].int else { return }
                                #if DEBUG
                                let tmp: Int = job_num - 5
                                print("JOB IDS", job_num, tmp)
                                #else
                                let tmp: Int = realm.objects(CoopResultsRealm.self).filter("nsaid=%@", nsaid).max(ofProperty: "job_id") ?? 0
                                #endif
                                if job_num == tmp { return }
                                let job_ids: Range<Int> = Range(max(job_num - 49, tmp + 1)...job_num)
                                
                                // SplatNet2からのリザルト取得に必要なパラメータ
                                var results: [JSON] = [] // リザルトを格納する配列
                                var salmon_ids: [(Int, Int)] = [] // Salmon StatsのIDとの整合性をとる
                                let times: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time }) // リザルトの重複チェックのための配列
                                
                                for (idx, job_num) in job_ids.enumerated() {
                                    messages.append("Downloading Result \(idx + 1) -> \(job_num)")
                                    let result: JSON = try SplatNet2.getResult(job_id: job_num, iksm_session: iksm_session)
                                    results.append(result)
                                }
                                
                                let data: [[Dictionary<String, Any>]] = results.map({ $0.dictionaryObject! }).chunked(by: 10)
                                for result in data {
                                    let response: JSON = SalmonStats.uploadSalmonStats(token: api_token, result)
                                    let ids: [(Int, Int)] = response.map({ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) })
                                    salmon_ids.append(contentsOf: ids)
                                    Thread.sleep(forTimeInterval: 3)
                                }
                                
                                // データの作成を行う
                                var nsaids: [String] = [] // 必要なIDたち
                                for result in results {
                                    let others: JSON = result["other_results"]
                                    nsaids.append(contentsOf: others.map({ $0.1["pid"].stringValue }))
                                    let job_id: Int = result["job_id"].intValue
                                    let salmon_id: Int? = salmon_ids.filter({ $0.0 == job_id }).first.map({ $0.1 })
                                    let result: CoopResultsRealm = JF.FromSplatNet2(nsaid: nsaid, salmon_id: salmon_id, result)
                                    let time: [Int] = times.filter({ abs($0 - result.play_time) < 10 })
                                    switch time.isEmpty {
                                    case true:
                                        realm.create(CoopResultsRealm.self, value: result, update: .modified)
                                    case false:
                                        let record = realm.objects(CoopResultsRealm.self).filter("play_time=%@", time.first!)
                                        record.setValue(result.job_id, forKey: "job_id")
                                        record.setValue(result.grade_point, forKey: "grade_point")
                                        record.setValue(result.grade_id, forKey: "grade_id")
                                        record.setValue(result.grade_point_delta, forKey: "grade_point_delta")
                                    }
                                }
                                nsaids.append(nsaid) // 自身のIDも追加
                                let crews: JSON = try SplatNet2.getPlayerNickName(Array(Set(nsaids)), iksm_session: iksm_session) // マッチングした仲間のデータを取得
                                for (_, crew) in crews["nickname_and_icons"] {
                                    let value: [String: Any] = ["nsaid": crew["nsa_id"].stringValue, "name": crew["nickname"].stringValue, "image": crew["thumbnail_url"].stringValue]
                                    realm.create(CrewInfoRealm.self, value: value, update: .all)
                                }

                                realm.create(UserInfoRealm.self, value: card as Any, update: .modified)
                                try realm.commitWrite()
                            } catch {
                                print("ACCOUNT \(nsaid) CREATE CARD FAILURE")
                                isLock = false
                            }
                        }
                    }
                    // そもそもデータが保持されていなかったときのエラー処理
                } catch APIError.Response(let code, let message){
                    messages.append("Error: \(code)")
                    messages.append(message)
                    messages.append("Please active/login NSO account")
                    isLock = false
                } catch {
                    messages.append("Fatal Error Occurs")
                    isLock = false
                }
                isLock = false
            }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
