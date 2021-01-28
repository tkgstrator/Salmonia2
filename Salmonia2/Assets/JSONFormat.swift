//
//  JSONFormat.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftyJSON
import RealmSwift

public let phase: [(start_time: Int, end_time: Int, stage_id: Int)] = Array(try! Realm().objects(CoopShiftRealm.self).map({ ($0.start_time, $0.end_time, $0.stage_id) }))

public class JF {
    
    class func FromFutureShift(_ response: JSON) -> CoopShiftRealm {
        
        let result: [String: Any?] = response.dictionaryObject!
        return CoopShiftRealm(value: result as Any)
        
    }
    
    class func FromSalmonStats(nsaid: String, _ response: JSON) -> CoopResultsRealm {
        
        let reasons: [Int: String?] = [
            0: nil,
            1: "wipe_out",
            2: "time_limit",
            3: nil
        ]
        
        let events: [Int: String] = [
            0: "-",
            1: "cohock-charge",
            2: "fog",
            3: "goldie-seeking",
            4: "griller",
            5: "the-mothership",
            6: "rush"
        ]
        
        let tides: [Int: String] = [
            1: "low",
            2: "normal",
            3: "high"
        ]
        
        func getGradeID(_ point: Int?) -> Int? {
            guard let point = point else { return nil }
            return min(5, 1 + (point / 100))
        }
        
        func getGradePoint(_ point: Int?) -> Int? {
            guard let point = point else { return nil }
            return point - min(4, (point / 100)) * 100
        }
        
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
            dict.updateValue(UnixTime.timestampFromDate(date: response["schedule_id"].stringValue), forKey: "start_time")
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
        
        let play_time: Int = UnixTime.timestampFromDate(date: response["start_at"].stringValue)
        let start_time: Int = UnixTime.timestampFromDate(date: response["schedule_id"].stringValue)
        // ある時期をすぎるとクラッシュするなこれ...
        //                let phase: JSON? = phases.filter{ $0["StartDateTime"].intValue == start_time}.first
        let end_time: Int? = phase.filter({ $0.start_time == start_time }).first?.end_time
        let stage_id: Int? = phase.filter({ $0.start_time == start_time }).first?.stage_id

        // 辞書型配列にガンガン追加していく
        let grade_point: Int? = my_results["grade_point"].int
        let clear_wave: Int = response["clear_waves"].intValue
        let fail_reason_id: Int? = response["fail_reason_id"].int
        
        dict.updateValue(end_time, forKey: "end_time") // シフトからとってこなきゃいけないのでめんどくさい
        dict.updateValue(stage_id, forKey: "stage_id") // ないんだが？？
        dict.updateValue(clear_wave == 3 ? nil : clear_wave + 1, forKey: "failure_wave")
        dict.updateValue(fail_reason_id == nil ? nil : reasons[fail_reason_id!], forKey: "failure_reason")
        dict.updateValue(getGradePoint(grade_point), forKey: "grade_point") // クソ適当（後で直す
        dict.updateValue(getGradeID(grade_point), forKey: "grade_id") // 求めてみた
        dict.updateValue(play_time, forKey: "play_time")
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
    
    class func FromSplatNet2(nsaid: String, salmon_id: Int?, _ response: JSON) -> CoopResultsRealm {
        // 辞書型に変換
        var result: [String: Any?] = response.dictionaryObject!
        
        //書き込み用のWaveとPlayerの情報を保持
        var waves: [WaveDetailRealm] = []
        var players: [PlayerResultsRealm] = []
        
        for (_, data) in response["wave_details"] {
            var wave = data.dictionaryObject
            // この処理ダサいからもっとかっこよく書きたい
            wave?.updateValue(data["event_type"]["key"].stringValue == "water-levels" ? "-" : data["event_type"]["key"].stringValue, forKey: "event_type")
            wave?.updateValue(data["water_level"]["key"].stringValue, forKey: "water_level")
            wave?.updateValue(response["start_time"].intValue, forKey: "start_time")
            waves.append(WaveDetailRealm(value: wave as Any))
        }
        
        // これをなんとかしたい（切実
        var player_results: [JSON] = []
        player_results.append(response["my_result"])
        for (_, other) in response["other_results"] {
            player_results.append(other)
        }
        
        var player_kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for data in player_results {
            var player = data.dictionaryObject
            let boss_kill_counts: [Int] = data["boss_kill_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue })
            let weapon_list: [Int] = data["weapon_list"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["id"].intValue })
            player?.updateValue(data["special"]["id"].intValue, forKey: "special_id")
            player?.updateValue(data["pid"].stringValue, forKey: "nsaid")
            player?.updateValue(boss_kill_counts, forKey: "boss_kill_counts")
            player?.updateValue(weapon_list, forKey: "weapon_list")
            players.append(PlayerResultsRealm(value: player as Any))
            player_kill_counts = Array(zip(player_kill_counts, boss_kill_counts)).map({ $0.0 + $0.1 })
        }
        result.updateValue(salmon_id as Any, forKey: "salmon_id")
        result.updateValue(response["job_result"]["failure_wave"].int as Any, forKey: "failure_wave")
        result.updateValue(response["job_result"]["failure_reason"].string as Any, forKey: "failure_reason")
        result.updateValue(response["job_result"]["is_clear"].bool as Any, forKey: "is_clear")
        result.updateValue(waves.map({ $0.ikura_num }).reduce(0, +), forKey: "power_eggs")
        result.updateValue(waves.map({ $0.golden_ikura_num }).reduce(0, +), forKey: "golden_eggs")
        result.updateValue(nsaid, forKey: "nsaid")
        result.updateValue(StageType(image_url: String(response["schedule"]["stage"]["image"].stringValue.suffix(44))), forKey: "stage_id")
        result.updateValue(response["grade"]["id"].intValue, forKey: "grade_id")
        result.updateValue(response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue }), forKey: "boss_counts")
        result.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        
        // Wave情報とPlayer情報を追加する
        result.updateValue(waves, forKey: "wave")
        result.updateValue(players, forKey: "player")
        return CoopResultsRealm(value: result as Any)
    }
}
