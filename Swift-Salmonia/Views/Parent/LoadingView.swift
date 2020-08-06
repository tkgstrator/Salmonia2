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
            // 重複しているかどうか調べるリスト（メインスレッドが一つだけもってメモリを節約）
            let results: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
            
            // 恐怖の完了ハンドラ
            SplatNet2.getSummaryFromSplatNet2(iksm_session: iksm_session) { response, error in
                guard let response = response else { return }
                let job_num_latest: Int = response["card"]["job_num"].intValue
                let job_num: Int = max(job_num_latest - 49, (realm.objects(CoopCardRealm.self).first?.job_num.value ?? 0))
                #if DEBUG
                // デバッガモードでは常に一件だけ取得
                #else
                if job_num == job_num_latest { return }
                #endif
                DispatchQueue.global().sync {
                    DispatchQueue(label: "Shifts").async {
                        autoreleasepool {
                            self.messages.append("Getting Shift Result")
                            guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                            realm.beginWrite()
                            // responseがnilということはエラー発生なのでエラー処理をここに書く
                            // 辞書型で読みこんで追加（ここ、うまくinit()かconfigure()で対応したいよね
                            var card: [String: Any]? = response["card"].dictionaryObject
                            card?.updateValue(nsaid, forKey: "nsaid")
                            realm.create(CoopCardRealm.self, value: card as Any, update: .modified)
                            for (_, data) in response["stats"] {
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
                        for job_id in job_num ... job_num_latest {
                            autoreleasepool {
                                SplatNet2.getResultFromSplatNet2(iksm_session: iksm_session, job_id: job_id) { response, error in
                                    // エラー処理
                                    guard let response = response else { return }
                                    // 非同期処理
                                    DispatchQueue(label: "Results").async {
                                        guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                        
                                        // 書き込むか書き込まないかに関わらず一応データは持っておく
                                        let result: CoopResultsRealm = SplatNet2.encodeResultToSplatNet2(response: response, nsaid: nsaid)
                                        // 自分と重複するデータがあるかを探す
                                        let play_time: Int? = results.filter({ abs($0 - result.play_time) < 10 }).first
                                        try? realm.write {
                                            // あるならアップデート、ないなら新規作成
                                            if play_time != nil {
                                                // 自身とかぶっているオブジェクト
                                                let record = realm.objects(CoopResultsRealm.self).filter("play_time=%@", play_time!)
                                                record.setValue(result.job_id, forKey: "job_id")
                                                record.setValue(result.grade_point, forKey: "grade_point")
                                                record.setValue(result.grade_id, forKey: "grade_id")
                                                record.setValue(result.grade_point_delta, forKey: "grade_point_delta")
                                            } else {
                                                realm.create(CoopResultsRealm.self, value: result, update: .modified)
                                            }
                                        }
                                    }
                                }
                            } // autoreleasepool
                            self.messages.append("Downloading Result \(job_id)")
                            Thread.sleep(forTimeInterval: 0.5)
                        } // For
                    } // DispatchQueue
                } // getSummary
                }
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
