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

// グローバル変数で強制的に同期処理にする（特に完了ハンドラてめーだ
private let semaphore = DispatchSemaphore(value: 0)
private let queue = DispatchQueue.global(qos: .utility)

struct LoadingView: View {
    @State var messages: [String] = []
    @State var isLock: Bool = true
    
    var body: some View {
        loggingThreadView(log: $messages, lock: $isLock)
            .onAppear() {
                // 最初にiksm_sessionをとっておきます
                guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else {
                    self.messages.append("Login SplatNet2")
                    self.isLock = false
                    return
                }
                guard let token: String = realm.objects(UserInfoRealm.self).first?.api_token else {
                    self.messages.append("Login Salmon Stats")
                    self.isLock = false
                    return
                }
                guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else {
                    self.messages.append("Can't get player id")
                    self.isLock = false
                    return
                }
                
                // iksm_sessionが有効かどうかを調べ、有効でない場合はsession_tokenから再取得するコード
                
                
                // 重複しているかどうか調べるリスト（メインスレッドが一つだけもってメモリを節約）
                let times: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
                let job_id_last: Int = realm.objects(CoopCardRealm.self).first?.job_num.value ?? 0
                var results: [JSON] = [] // リザルト保存用の配列（大したサイズでないから大丈夫なはず
                var salmon_ids: [(Int, Int)] = []
                
                print("SUMMARY START")
                DispatchQueue(label: "Summary").async {
                    // 公式の統計情報について処理を行う
                    let response: JSON = SplatNet2.getSummaryFromSplatNet2(iksm_session)
                    
                    // 取得すべきバイトIDの計算を行う
                    let job_id_latest: Int = response["card"]["job_num"].intValue
                    if job_id_last == job_id_latest {
                        self.messages.append("No new result")
                        self.isLock = false
                        return
                    }
                    print(job_id_last, job_id_latest)
                    let job_ids: Range<Int> = Range(max(job_id_latest - 49, job_id_last + 1)...job_id_latest)
                    
                    self.messages.append("Getting Shift Result")
                    autoreleasepool {
                        guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                        realm.beginWrite()
                        
                        // バイト全体の統計情報
                        var card: [String: Any]? = response["card"].dictionaryObject
                        card?.updateValue(nsaid, forKey: "nsaid")
                        realm.create(CoopCardRealm.self, value: card as Any, update: .modified)
                        
                        // 最新のシフト数件の公式の統計情報
                        for (i, data) in response["stats"] {
                            print(i, data.count)
                            self.messages.append("Getting Shift Result \(i)/\(data.count / 3)")
                            guard let realm = try? Realm() else { return }
                            var shift = data.dictionaryObject
                            // nsaidとsashを追加
                            shift?.updateValue(nsaid, forKey: "nsaid")
                            shift?.updateValue((nsaid + String(data["start_time"].intValue)).sha256(), forKey: "sash")
                            // ブキ情報を追加
                            let weapons: [Int] = data["schedule"]["weapons"].map({ $0.1["id"].intValue })
                            shift?.updateValue(weapons, forKey: "weapons")
                            realm.create(ShiftResultsRealm.self, value: shift as Any, update: .modified)
                            Thread.sleep(forTimeInterval: 0.5)
                        }
                        try? realm.commitWrite()
                    }
                    // ここではひたすらダウンロードして貯めるだけ（書き込まないのである程度速くて良い
                    for (i, job_id) in job_ids.enumerated() {
                        self.messages.append("Getting Result \(job_id) \(i + 1)/\(job_ids.count)")
                        results.append(SplatNet2.getResultFromSplatNet2(iksm_session, job_id))
                    }
                    
                    // Salmon Statsアップロード用のデータにする（最大10件アップロード
                    let data: [[Dictionary<String, Any>]] = results.map({ $0.dictionaryObject! }).chunked(by: 10)
                    
                    // 5秒おきにSalmon Statsへアップロードする機能
                    DispatchQueue(label: "SalmonStats").async {
                        for result in data {
                            let response: JSON = SalmonStats.uploadSalmonStats(token: token, result)
                            // 一方しか持っていないので不測の事態でバグるかも...
                            let ids: [(Int, Int)] = response.map({ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) })
                            salmon_ids.append(contentsOf: ids)
                            Thread.sleep(forTimeInterval: 5)
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                    // ダウンロードした履歴をRealmに変換して書き込むところ
                    autoreleasepool {
                        guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                        realm.beginWrite()
                        for result in results {
                            let job_id: Int = result["job_id"].intValue
                            let salmon_id: Int? = salmon_ids.filter({ $0.0 == job_id }).first.map({ $0.1 })
                            let result: CoopResultsRealm = SplatNet2.encodeResultFromJSON(nsaid: nsaid, salmon_id: salmon_id, result)
                            let time: [Int] = times.filter({ abs($0 - result.play_time) < 10 })
                            // 重複するデータがないので書き込む
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
                        try? realm.commitWrite()
                    }
                    self.isLock = false
                }
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread")
    }
}


struct SyncUserNameView: View {
    @State var messages: [String] = []
    @State var isLock: Bool = true
    
    private let phases = try! JSON(data: NSData(contentsOfFile: Bundle.main.path(forResource: "formated_future_shifts", ofType:"json")!) as Data)
    private let shifts: [Int] = CoopResultsRealm.gettime()
    
    var body: some View {
        loggingThreadView(log: $messages, lock: $isLock)
            .onAppear() {
                // 重複を除いたnsaidを取得する
                DispatchQueue(label: "SplatNet2").async {
                    let nsaid: [[String]] = PlayerResultsRealm.getids().chunked(by: 200)
                    DispatchQueue(label: "NSAID").async {
                        for list in nsaid {
                            autoreleasepool {
                                SplatNet2.getPlayerNickname(nsaid: list) { response, error in
                                    guard let response = response else { return }
                                    DispatchQueue(label: "NickName").async {
                                        guard let realm = try? Realm() else { return }
                                        realm.beginWrite()
                                        for (_, value) in response {
                                            self.messages.append("\(value["nsa_id"].stringValue) -> \(value["nickname"].stringValue)")
                                            let crew = CrewInfoRealm()
                                            crew.nsaid = value["nsa_id"].string
                                            crew.name = value["nickname"].string
                                            crew.image = value["thumbnail_url"].string
                                            realm.create(CrewInfoRealm.self, value: crew, update: .modified)
                                            realm.objects(PlayerResultsRealm.self).filter("nsaid=%@", crew.nsaid as Any).setValue(crew.name, forKey: "name")
                                        }
                                        try? realm.commitWrite()
                                    }
                                }
                            }
                            Thread.sleep(forTimeInterval: 5)
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                    self.isLock = false
                }
        }
    }
}


struct ImportedView: View {
    @State var messages: [String] = []
    @State var isLock: Bool = false
    
    var body: some View {
        loggingThreadView(log: $messages, lock: $isLock)
            .onAppear() {
                guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                guard let is_imported: Bool = realm.objects(UserInfoRealm.self).first?.is_imported else { return }
                guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
                // データ重複していないかどうか調べるための配列リスト
                let results: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
                // データの取り込みは一度しか許可しない
                if is_imported == true { return }
                
                self.messages.append("Importing Results from Salmon Stats")
                self.isLock = true
                DispatchQueue(label: "Imported").async {
                    let last: Int = SalmonStats.getResultsLastLink(nsaid: nsaid)
                    DispatchQueue(label: "GetPages").async {
                        for page in 1...last {
                            let imported: JSON = SalmonStats.importResultsFromSalmonStats(nsaid: nsaid, page: page)
                            autoreleasepool {
                                guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                realm.beginWrite()
                                for (idx, result) in imported {
                                    let start_time = Unixtime(time: result["start_at"].stringValue)
                                    if results.filter({ abs($0 - start_time) <= 10 }).isEmpty {
                                        let object: CoopResultsRealm = SalmonStats.encodeResultToSplatNet2(nsaid: nsaid, result)
                                        realm.create(CoopResultsRealm.self, value: object, update: .modified)
                                    }
                                    self.messages.append("Result: \((page - 1) * 200 + Int(idx)! + 1) -> \(result["id"].intValue)")
                                } // For
                                // 200件に1回データを書き込む（そうでないと書き込み過多になる
                                try? realm.commitWrite()
                            } // autoreleasepool
                            Thread.sleep(forTimeInterval: 10) // Salmon Statsへのアクセス間隔を20秒置きにする
                        } // For
                        print("SIGNAL")
                        semaphore.signal()
                    } // DispatchQueue
                    semaphore.wait()
                    self.isLock = false
                    print("WAIT")
                }
        }
    }
}


// ログを表示するためのビュー
// 文字列リストでメッセージを渡せば良い
private struct loggingThreadView: View {
    @Binding var log: [String]
    @Binding var lock: Bool
    
    init(log: Binding<[String]>, lock: Binding<Bool>) {
        _log = log
        _lock = lock
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        Group {
            VStack {
                Text("Developed by @tkgling")
                Text("Thanks @Yukinkling, @barley_ural")
                Text("External API @frozenpandaman, @nexusmine")
            }
            List {
                ForEach(log.indices, id:\.self) { idx in
                    Text(self.log[idx]).frame(height: 10)
                }
            }.environment(\.defaultMinListRowHeight, 0)
        }
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread")
        .navigationBarBackButtonHidden(lock)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
