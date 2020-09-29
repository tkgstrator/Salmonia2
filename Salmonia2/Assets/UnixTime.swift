//
//  UnixTime.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-23.
//

import Foundation
import RealmSwift

public class UnixTime {
    public class func dateFromTimestamp(_ interval: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(interval)))
    }
    
//    public class func timestampFromSalmonStats(_ interval: Int) ->
}

func SRPower(_ results: Results<CoopResultsRealm>) -> [Double] {
    let bossrate: [Int] = [1783, 1609, 2649, 1587, 1534, 1563, 1500, 1783, 2042]
    var ilorate: [Double] = [0.0, 0.0]
    var tmprate: Double = 0.0
    
    let win_count: Int = results.prefix(10).filter({$0.is_clear == true}).count

    for (idx, result) in results.enumerated() {
        let player = result.player[0]
        let bias = CalcBias(result)
        let baserate: Int = (Array(zip(bossrate, Array(player.boss_kill_counts))).map({$0 * $1}).reduce(0, +)) / max(1, player.boss_kill_counts .sum())
        let salmonrate: Double = min(bias * Double(baserate), 3074.5).round(digit: 2)
        
        switch idx {
        case (0...9):
            tmprate += salmonrate
            if idx == 9 {
                tmprate = (tmprate / 10).round(digit: 2)
                switch win_count {
                case 0:
                    ilorate[0] = tmprate - 400
                    ilorate[1] = tmprate - 400
                case 10:
                    ilorate[0] = tmprate + 400
                    ilorate[1] = tmprate + 400
                default:
                    ilorate[0] = (tmprate + 400 * log10(Double(win_count)/Double(10 - win_count))).round(digit: 2)
                    ilorate[1] = (tmprate + 400 * log10(Double(win_count)/Double(10 - win_count))).round(digit: 2)
                }
            }
        default:
            let delta: Double = result.is_clear ? min((32 / (pow(10, (ilorate[0] - salmonrate) / 400) + 1)), 32.0) : max(-1 * 32 / (pow(10, (salmonrate - ilorate[0]) / 400) + 1), -32.0)
            ilorate[1] = max(ilorate[0] + delta, ilorate[1]).round(digit: 2)
            ilorate[0] = (ilorate[0] + delta).round(digit: 2)
        }
        print(baserate, bias, salmonrate, ilorate)
    }
    return ilorate
}

func CalcBias(_ result: CoopResultsRealm) -> Double {
    let rate: Double = (Double(min(result.grade_point.value ?? Int(result.danger_rate) * 3, 600)) / 5.0 + 80) / 160.0
    let max_bias: Double = result.grade_point.value ?? Int(result.danger_rate) * 3 >= 600 ? 1.5 : 1.25
    var bias: (defeated: Double, golden: Double) = (0.0, 0.0)
    
    let quota_num = result.wave.map({ $0.quota_num }).reduce(0, +)
    let defeated_num = result.player[0].boss_kill_counts.sum()
    let appear_num = result.boss_counts.sum()
    
    if (result.player[0].golden_ikura_num * 4 >= quota_num && defeated_num * 4 >= appear_num && defeated_num > 0) {
        bias.defeated = min(Double(defeated_num * 99) / Double(17 * defeated_num), max_bias)
    }
    
    if (result.player[0].golden_ikura_num * 3 >= quota_num && defeated_num * 5 >= appear_num) {
        bias.golden = min(rate + Double(10 * (result.player[0].golden_ikura_num * 3 - quota_num)) / (9.0 * 160.0), max_bias)
    }
//    print(bias.defeated, bias.golden, rate)
    return max(bias.defeated, bias.golden, rate)
    
}
