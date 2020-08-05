//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON
import CryptoSwift

struct LoadingView: View {
    @State var messages: [String] = []
    
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Logging Thread").frame(maxWidth: .infinity)
                    ForEach(messages.indices, id: \.self) { idx in
                        Text(self.messages[idx])
                    }
                }
            }
        }
        .onAppear() {
            // 最初にiksm_sessionをとっておきます
            guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
            guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
            guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
            let job_num: Int = realm.objects(CoopCardRealm.self).first?.job_num.value ?? 0

            // 恐怖の完了ハンドラ
            SplatNet2.getSummaryFromSplatNet2(iksm_session: iksm_session) { response, error in
                DispatchQueue(label: "Shifts").async {
                    autoreleasepool {
                        guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                        realm.beginWrite()
                        // responseがnilということはエラー発生なのでエラー処理をここに書く
                        guard let response = response else { return }
                        // 辞書型で読みこんで追加（ここ、うまくinit()かconfigure()で対応したいよね
                        var card: [String: Any]? = response["card"].dictionaryObject
                        card?.updateValue(nsaid, forKey: "nsaid")
                        realm.create(CoopCardRealm.self, value: card as Any, update: .modified)
                        for (_, data) in response["stats"] {
                            self.messages.append("Getting Coop Card Data")
                            Thread.sleep(forTimeInterval: 1)
                            guard let realm = try? Realm() else { return }
                            var shift = data.dictionaryObject
                            // nsaidとsashを追加
                            shift?.updateValue(nsaid, forKey: "nsaid")
                            shift?.updateValue((nsaid + String(data["start_time"].intValue)).sha256(), forKey: "sash")
                            // ブキ情報を追加
                            let weapons: [Int] = data["schedule"]["weapons"].map({ $0.1["id"].intValue })
                            shift?.updateValue(weapons, forKey: "weapons")
                            realm.create(ShiftResultsRealm.self, value: shift as Any, update: .modified)
                        }
                        try? Realm().commitWrite()
                    } // autoreleasepool
                } // DispatchQueue
                DispatchQueue(label: "Results").async {
                    for job_id in 2390 ... 2390 {
                        autoreleasepool {
                            SplatNet2.getResultFromSplatNet2(iksm_session: iksm_session, job_id: job_id) { response, error in
                                // エラー処理
                                guard let response = response else { return }
                                // 非同期処理
                                DispatchQueue(label: "Results").async {
                                    guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                    var result = response.dictionaryObject
                                    //書き込み用のWaveとPlayerの情報を保持
                                    var waves: [WaveDetailRealm] = []
                                    var players: [PlayerResultsRealm] = []
                                    
                                    for (_, data) in response["wave_details"] {
                                        var wave = data.dictionaryObject
                                        // この処理ダサいからもっとかっこよく書きたい
                                        wave?.updateValue(data["event_type"]["key"].stringValue == "water-levels" ? "-" : data["event_type"]["key"].stringValue, forKey: "event_type")
                                        wave?.updateValue(data["water_level"]["key"].stringValue, forKey: "water_level")
                                        wave?.updateValue(response["start_time"].intValue, forKey: "start_time")
                                        waves.append(WaveDetailRealm(value: wave))
                                    }
                                    for (_, data) in response["other_results"] {
                                        var player = data.dictionaryObject
                                        let boss_kill_counts: [Int] = data["boss_kill_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue })
                                        let weapon_list: [Int] = data["weapon_list"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["id"].intValue })
                                        player?.updateValue(data["special"]["id"].intValue, forKey: "special_id")
                                        player?.updateValue(data["pid"].stringValue, forKey: "nsaid")
                                        player?.updateValue(boss_kill_counts, forKey: "boss_kill_counts")
                                        player?.updateValue(weapon_list, forKey: "weapon_list")
                                        players.append(PlayerResultsRealm(value: player))
                                    }
                                    result?.updateValue(waves.map({ $0.ikura_num }).reduce(0, +), forKey: "power_eggs")
                                    result?.updateValue(waves.map({ $0.golden_ikura_num }).reduce(0, +), forKey: "golden_eggs")
                                    result?.updateValue(nsaid, forKey: "nsaid")
                                    result?.updateValue(Stage(url: String(response["schedule"]["stage"]["image"].stringValue.suffix(44))), forKey: "stage_name")
                                    result?.updateValue(response["grade"]["id"].intValue, forKey: "grade_id")
                                    result?.updateValue(response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue }), forKey: "appear")
                                    
                                    // Wave情報とPlayer情報を追加する
                                    result?.updateValue(waves, forKey: "wave")
                                    result?.updateValue(players, forKey: "player")
                                    // 予約してすぐ書き込むから意味があるかは謎
                                    realm.beginWrite()
                                    realm.create(CoopResultsRealm.self, value: result, update: .modified)
                                    try? Realm().commitWrite()
                                }
                            }
                        } // autoreleasepool
                        self.messages.append("Downloading Result \(job_num)")
                        Thread.sleep(forTimeInterval: 1)
                    } // For
                } // DispatchQueue
            } // getSummary
            
            //                SplatNet2.getResultFromSplatNet2(iksm_session: iksm_session, job_id: job_id) {
            //
            //                }
            
            //            let time = Int(Date().timeIntervalSince1970)
            //            DispatchQueue(label: "SplatNet2").async() {
            //                autoreleasepool {
            //                    guard let realm = try? Realm() else { return }
            //                    realm.beginWrite()
            //                    for idx in 0..<100 {
            //                        SplatNet2.getSummaryFromSplatNet2(iksm_session: iksm_session, nsaid: nsaid) { response, error in
            //                            realm.create(CoopCardRealm.self, value: response!["card"].dictionaryObject)
            //                        }
            //                        self.messages.append("\(Int(Date().timeIntervalSince1970) - time) LOOP: \(idx)")
            //                        Thread.sleep(forTimeInterval: 1)
            //
            //                    }
            //                    try? Realm().commitWrite()
            //                }
            //            }
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread")
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
