//
//  JSONFormat.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftyJSON

class JF {
    
    class func FromFutureShift(_ response: JSON) -> FutureShiftRealm {
        
        let result: [String: Any?] = response.dictionaryObject!
        return FutureShiftRealm(value: result as Any)
        
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
        result.updateValue(SP2Map.getStageId(String(response["schedule"]["stage"]["image"].stringValue.suffix(44))), forKey: "stage_id")
        result.updateValue(response["grade"]["id"].intValue, forKey: "grade_id")
        result.updateValue(response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue }), forKey: "boss_counts")
        result.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        
        // Wave情報とPlayer情報を追加する
        result.updateValue(waves, forKey: "wave")
        result.updateValue(players, forKey: "player")
        return CoopResultsRealm(value: result as Any)
    }
}
