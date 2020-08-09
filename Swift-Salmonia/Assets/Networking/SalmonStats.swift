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

private let semaphore = DispatchSemaphore(value: 0)
private let queue = DispatchQueue.global(qos: .utility)

class SalmonStats {
    static let realm = try! Realm() // 多分存在するやろ
    
    static private let reasons: [Int: String?] = [
        0: nil,
        1: "wipe_out",
        2: "time_limit",
        3: nil
    ]
    
    static private let events: [Int: String] = [
        0: "-",
        1: "cohock-charge",
        2: "fog",
        3: "goldie-seeking",
        4: "griller",
        5: "the-mothership",
        6: "rush"
    ]
    
    static private let tides: [Int: String] = [
        1: "low",
        2: "normal",
        3: "high"
    ]
    

    
    static private let phases: [JSON] = try! JSON(data: NSData(contentsOfFile: Bundle.main.path(forResource: "formated_future_shifts", ofType:"json")!) as Data).array!
    
    // 評価値からサーモンランのウデマエIDを返す（だいたいたつじんだろうとおもうけれど...
    private class func getGradeID(_ point: Int?) -> Int? {
        guard let point = point else { return nil }
        return min(5, 1 + (point / 100))
    }
    
    // 評価レートを計算する関数
    private class func getGradePoint(_ point: Int?) -> Int? {
        guard let point = point else { return nil }
        return point - min(4, (point / 100)) * 100
    }
    
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
    
    // プレイヤーの最新10件のシフトデータを取得
    class func getPlayerShiftStats(nsaid: String, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/schedules"
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
//                print(JSON(value))
                completion(JSON(value)["data"])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    class func getPlayerShiftStatsDetail(nsaid: String, start_time: Int, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/schedules/\(start_time)"
        
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
    
    class func uploadSalmonStats(token: String, _ results: [Dictionary<String, Any>]) -> JSON {
        let url = "https://salmon-stats-api.yuki.games/api/results"
        let header: HTTPHeaders = [
            "Content-type": "application/json",
            "Authorization": "Bearer " + token
        ]
        let body = ["results": results]
        
        var salmon_ids: JSON = JSON()
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    salmon_ids = JSON(value)
                case .failure(let error):
                    print(error)
                }
                semaphore.signal()
        }
        semaphore.wait()
        return salmon_ids
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
    
    class func getResultsLastLink(nsaid: String) -> Int {
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        
        var link: Int = 0
        AF.request(url, method: .get)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    let metadata = JSON(value)[0]["results"]
                    // ちょっと曖昧なので怪しいかもしれない
                    link = 1 + (metadata["clear"].intValue + metadata["fail"].intValue) / 200
                case .failure:
                    print("ERROR")
                }
                semaphore.signal()
        }
        semaphore.wait()
        print("LAST PAGE", link)
        return link
        
        // 仕様変更で動かなくなったので変更
        //        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200"
        //
        //        var link: Int = 0
        //        AF.request(url, method: .get)
        //            .validate(contentType: ["application/json"])
        //            .responseJSON(queue: queue) { response in
        //                switch response.result {
        //                case .success(let value):
        //                    link = JSON(value)["to"].intValue
        //                case .failure:
        //                    print("ERROR")
        //                }
        //                semaphore.signal()
        //        }
        //        semaphore.wait()
        //        print("LAST PAGE", link)
        //        return link
    }
    
    class func importResultsFromSalmonStats(nsaid: String, page: Int) -> JSON {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200&page=\(page)"
        
        var results: JSON = JSON()
        AF.request(url, method: .get)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    results = JSON(value)["results"]
                case .failure:
                    print("ERROR")
                }
                semaphore.signal()
        }
        semaphore.wait()
        return results
    }
   
    class func encodeStats(_ response: JSON) -> SalmonStatsFormat {
        let summary: JSON = response["summary"]
        let global: JSON = response["global"]
        
        let boss_ids: [Int] = [3, 6, 9, 12, 13, 14, 15, 16, 21]
        var stats: SalmonStatsFormat = SalmonStatsFormat()

        let clear_games = summary["clear_games"].intValue
        let games = summary["games"].intValue
        let clear_ratio: Double = (Double(clear_games) / Double(games)).round(digit: 4)

        stats.games = games
        stats.clear_ratio = clear_ratio

        for id in boss_ids {
            let s_appear: Double = Double(summary["boss_appearance_\(id)"].intValue)
            let s_defeat: Double = Double(summary["player_boss_elimination_\(id)"].intValue)
            let g_appear: Double = Double(global["boss_appearance_\(id)"].intValue)
            let g_defeat: Double = Double(global["boss_elimination_\(id)"].intValue)
            stats.my_defeated.append((s_defeat/s_appear).round(digit: 4))
            stats.other_defeated.append((g_defeat/g_appear/4.0).round(digit: 4))
        }
        
        return stats
    }
    
    class func encodeResultToSplatNet2(nsaid: String, _ response: JSON) -> CoopResultsRealm {
        var dict: [String: Any?] = [:]
        var waves: [WaveDetailRealm] = []
        var players: [PlayerResultsRealm] = []
        
        // 全員分の空の配列を用意
        let my_results: JSON = response["player_results"].filter({ $0.1["player_id"].stringValue == nsaid }).first!.1
        var other_results: [JSON] = response["player_results"].filter({ $0.1["player_id"].stringValue != nsaid }).map({ $0.1 })
        other_results.insert(my_results, at: 0)
        
        for (_, wave) in response["waves"] {
            var dict: [String: Any] = [:]
            dict.updateValue(events[wave["event_id"].intValue]!, forKey: "event_type")
            dict.updateValue(tides[wave["water_id"].intValue]!, forKey: "water_level")
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
        
        let start_time: Int = Unixtime(time: response["schedule_id"].stringValue)
        
        // ある時期をすぎるとクラッシュするなこれ...
        let phase: JSON? = phases.filter{ $0["StartDateTime"].intValue == start_time}.first
        let end_time: Int? = phase?["EndDateTime"].intValue
        let stage_id: Int? = phase?["StageID"].intValue
        
        // 辞書型配列にガンガン追加していく
        let grade_point: Int? = my_results["grade_point"].int
        let clear_wave: Int = response["clear_waves"].intValue
        
        dict.updateValue(end_time, forKey: "end_time") // シフトからとってこなきゃいけないのでめんどくさい
        dict.updateValue(stage_id, forKey: "stage_id") // ないんだが？？
        dict.updateValue(clear_wave == 3 ? nil : clear_wave + 1, forKey: "failure_wave")
        dict.updateValue(reasons[clear_wave]!, forKey: "failure_reason")
        dict.updateValue(getGradePoint(grade_point), forKey: "grade_point") // クソ適当（後で直す
        dict.updateValue(getGradeID(grade_point), forKey: "grade_id") // 求めてみた
        dict.updateValue(Unixtime(time: response["start_at"].stringValue), forKey: "play_time")
        dict.updateValue(nsaid, forKey: "nsaid")
        dict.updateValue(nil, forKey: "job_id") // これがないのは知っている
        dict.updateValue(response["id"].intValue, forKey: "salmon_id")
        dict.updateValue(start_time, forKey: "start_time")
        dict.updateValue(response["danger_rate"].doubleValue, forKey: "danger_rate")
        dict.updateValue(response["golden_egg_delivered"].intValue, forKey: "golden_eggs")
        dict.updateValue(response["power_egg_collected"].intValue, forKey: "power_eggs")
        dict.updateValue(response["fail_reason_id"] == JSON.null, forKey: "is_clear")
        dict.updateValue(response["boss_appearances"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1.intValue }), forKey: "boss_counts")
        dict.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        dict.updateValue(waves, forKey: "wave")
        dict.updateValue(players, forKey: "player")
        return CoopResultsRealm(value: dict)
    }
}

struct SalmonStatsFormat {
    public var games: Int = 0
    public var clear_ratio: Double = 0
    public var my_defeated: [Double] = []
    public var other_defeated: [Double] = []
    
    init() { }
}
