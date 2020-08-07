//
//  SalmonStats.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import WebKit

class SalmonStats {
    
    static let realm = try! Realm() // 多分存在するやろ
    
    // プレイヤーの戦績一覧を取得
    class func getPlayerOverView(nsaid: String, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=" + nsaid
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                completion(JSON(value))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // プレイヤーの最新のリザルト10件の概要を取得
    class func getPlayerOverViewResults(nsaid: String, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/" + nsaid
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                completion(JSON(value)["results"])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // エラーコード1001を返す
    class func loginSalmonStats(completion: @escaping (Error?) -> ()) {
        WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
            cookies in
            for cookie in cookies {
                if cookie.name == "laravel_session" {
                    let laravel_session = cookie.value
                    getTokenFromSalmonStats(session_token: laravel_session) { response, error in
                        guard let token = response?["api_token"].stringValue else {
                            completion(APPError.Response(id: 1001, message: "Login Salmon Statsr"))
                            return }
                        guard let user = realm.objects(UserInfoRealm.self).first else { return }
                        // データベース書き込み
                        do {
                            try realm.write { user.setValue(token, forKey: "api_token") }
                        } catch {
                            completion(APPError.Database(id: 1001, message: "Realm write error"))
                        }
                    }
                }
            }
        }
    }
    
    // エラーコード1000を返す
    class func getTokenFromSalmonStats(session_token: String, completion: @escaping  (JSON?, Error?) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api-token"
        let header: HTTPHeaders = [
            "Cookie" : "laravel_session=" + session_token
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value), nil)
                case .failure:
                    // レスポンスがおかしいことを示した上でリターン
                    completion(nil, APPError.Response(id: 1000, message: "Server Error"))
                }
        }
    }
    
    class func getResultsLink(nsaid: String, completion: @escaping (Int?, Error?) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200"
        
        AF.request(url, method: .get)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let first: Int = JSON(value)["to"].intValue
                    completion(first, nil)
                case .failure:
                    completion(nil, APPError.Response(id: 3000, message: "Server Error"))
                }
        }
    }
    
    class func importResultsFromSalmonStats(nsaid: String, page: Int, completion: @escaping (JSON?, Error?) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200&page=\(page)"

        AF.request(url, method: .get)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value)["results"], nil)
                case .failure:
                    completion(nil, APPError.Response(id: 3000, message: "Server Error"))
                }
        }
    }
    
    class func encodeResultToSplatNet2(response: JSON, nsaid: String) -> CoopResultsRealm {
        var dict: [String: Any?] = [:]
        var waves: [WaveDetailRealm] = []
        var players: [PlayerResultsRealm] = []
        
        // 全員分の空の配列を用意
        let my_results: JSON = response["player_results"].filter({ $0.1["player_id"].stringValue == nsaid }).first!.1
        var other_results: [JSON] = response["player_results"].filter({ $0.1["player_id"].stringValue != nsaid }).map({ $0.1 })
        other_results.insert(my_results, at: 0)

        for (_, wave) in response["waves"] {
            var dict: [String: Any] = [:]
            dict.updateValue(Event(id: wave["event_id"].intValue), forKey: "event_type")
            dict.updateValue(Tide(id: wave["water_id"].intValue), forKey: "water_level")
            dict.updateValue(wave["golden_egg_delivered"].intValue, forKey: "golden_ikura_num")
            dict.updateValue(wave["golden_egg_appearances"].intValue, forKey: "golden_ikura_pop_num")
            dict.updateValue(wave["golden_egg_quota"].intValue, forKey: "quota_num")
            dict.updateValue(wave["power_egg_collected"].intValue, forKey: "ikura_num")
            dict.updateValue(Unixtime(time: response["schedule_id"].stringValue), forKey: "start_time")
            waves.append(WaveDetailRealm(value: dict))
        }

        var player_kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for player in other_results {
            var dict: [String: Any] = [:]
            let kill_counts = player["boss_eliminations"]["counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1.intValue })
            dict.updateValue(player["player_id"].stringValue, forKey: "nsaid")
            dict.updateValue(player["death"].intValue, forKey: "dead_count")
            dict.updateValue(player["rescue"].intValue, forKey: "help_count")
            dict.updateValue(player["golden_eggs"].intValue, forKey: "golden_ikura_num")
            dict.updateValue(player["power_eggs"].intValue, forKey: "ikura_num")
//            dict.updateValue(player["player_id"].stringValue, forKey: "name") // プレイヤー名が入ってないですね
            dict.updateValue(player["special_id"].intValue, forKey: "special_id")
            dict.updateValue(kill_counts, forKey: "boss_kill_counts")
            dict.updateValue(player["weapons"].map({ $0.1["weapon_id"].intValue }), forKey: "weapon_list")
            dict.updateValue(player["special_uses"].map({ $0.1["count"].intValue }), forKey: "special_counts")
            player_kill_counts = Array(zip(player_kill_counts, kill_counts)).map({ $0.0 + $0.1 })
            players.append(PlayerResultsRealm(value: dict))
        }

        // クソダサだけど多分これで動く（読み込みめんどくね？）
        let start_time: Int = Unixtime(time: response["schedule_id"].stringValue)
        // これも結局毎回読み込んでるから重いのでは
//        let phase: JSON = CoopCore().getShiftData(start_time: start_time)

        // ある時期をすぎるとクラッシュするなこれ...
//        let end_time: Int = phase["EndDateTime"].intValue
//        let stage_name: String = Stage(name: phase["StageID"].intValue)
        
        // 辞書型配列にガンガン追加していく
        let grade_point: Int? = my_results["grade_point"].int
        let clear_wave: Int = response["clear_waves"].intValue
        dict.updateValue(Unixtime(time: response["start_at"].stringValue), forKey: "play_time")
        dict.updateValue(nsaid, forKey: "nsaid")
        dict.updateValue(nil, forKey: "job_id") // これがないのは知っている
        dict.updateValue(response["id"].intValue, forKey: "salmon_id")
//        dict.updateValue("", forKey: "stage_name") // ないんだが？？
        dict.updateValue(Grade(point: grade_point), forKey: "grade_point") // クソ適当（後で直す
        dict.updateValue(GradeID(point: grade_point), forKey: "grade_id") // 求めてみた
        dict.updateValue(start_time, forKey: "start_time")
        dict.updateValue(Failure(waves: clear_wave), forKey: "failure_wave")
        dict.updateValue(Reason(id: response["fail_reason_id"].intValue), forKey: "failure_reason")
        dict.updateValue(response["danger_rate"].doubleValue, forKey: "danger_rate")
        dict.updateValue(GradeDelta(wave: clear_wave), forKey: "grade_point_delta") // ここは計算可能
//        dict.updateValue(end_time, forKey: "end_time") // シフトからとってこなきゃいけないのでめんどくさい
        dict.updateValue(response["golden_egg_delivered"].intValue, forKey: "golden_eggs")
        dict.updateValue(response["power_egg_collected"].intValue, forKey: "power_eggs")
        dict.updateValue(response["fail_reason_id"] == JSON.null, forKey: "is_clear")
        dict.updateValue(response["boss_appearances"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1.intValue }), forKey: "boss_counts")
        dict.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        dict.updateValue(waves, forKey: "wave")
        dict.updateValue(players, forKey: "player")
        return CoopResultsRealm(value: dict)
    }
    
    class func importResultsFromSalmonStats() {
        guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
        guard let is_imported: Bool = realm.objects(UserInfoRealm.self).first?.is_imported else { return }
        guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
        
        // データ重複していないかどうか調べるための配列リスト
        let results: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
        // データの取り込みは一度しか許可しない
        if is_imported == true { return }
        
//        self.messages.append("Importing Results from Salmon Stats")
        SalmonStats.getResultsLink(nsaid: nsaid) { last, error in
            // エラーが発生した場合、それを返す
            guard var last = last else { return }
            #if DEBUG
            last = 3
            #else
            #endif
            DispatchQueue(label: "GetPages").async {
                for page in 1...last {
                    SalmonStats.importResultsFromSalmonStats(nsaid: nsaid, page: page) { response, error in
                        DispatchQueue(label: "SalmonStats").async {
                            autoreleasepool {
                                guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                guard let response = response else { return }
                                realm.beginWrite()
                                for (idx, result) in response {
                                    let start_time = Unixtime(time: result["start_at"].stringValue)
                                    // 10秒以内に新規リザルトをつくることは不可能なのでその間としてみる
                                    let is_valid: Bool = results.filter({ abs($0 - start_time) <= 10 }).count == 0
                                    if is_valid {
                                        let object: CoopResultsRealm = SalmonStats.encodeResultToSplatNet2(response: result, nsaid: nsaid)
                                        realm.create(CoopResultsRealm.self, value: object, update: .modified)
                                    }
                                    print("\((page - 1) * 200 + Int(idx)!) -> \(result["id"].intValue) \(is_valid)")
//                                    self.messages.append("Result: \((page - 1) * 200 + Int(idx)!) -> \(result["id"].intValue) \(is_valid)")
                                    Thread.sleep(forTimeInterval: 0.1)
                                } // For
                                try? realm.commitWrite()
                            } // autoreleasepool
                        } // DispatchQueue in closure
                    } // importResultsFromSalmonStats
                    Thread.sleep(forTimeInterval: 20)
                } // For
            } // DispatchQueue
        } // GetResultsLink
    }
//    class func getShiftData() -> JSON {
//        let phases = try! JSON(data: NSData(contentsOfFile: Bundle.main.path(forResource: "formated_future_shifts", ofType:"json")!) as Data)
//        return phases.filter( {$0.1["StartDateTime"].intValue == start_time }).first!.1
//        
//    }
}
