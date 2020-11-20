//
//  ChartCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-19.
//

import Foundation
import SwiftUI
import RealmSwift

class ChartCore: ObservableObject {
    
    private var token: NotificationToken?
    @Binding var start_time: Int
    //    @Published var data: [DataPoint] = []
    //    @Published var dimension: DataDimension = DataDimension()
    
    @Published var defeated: (data: [DataPoint], dimension: DataDimension) = ([], DataDimension())
    @Published var overview: (data: [DataPoint], dimension: DataDimension) = ([], DataDimension())
    
    init(start_time: Binding<Int>) {
        self._start_time = start_time
        token = try? Realm().objects(CoopResultsRealm.self).observe { _ in
            guard let results = try? Realm().objects(CoopResultsRealm.self).filter("start_time=%@", self.start_time) else { return }
//            guard let summary = try? Realm().objects(ShiftResultsRealm.self).filter("start_time=%@",self.start_time).first else { return }
//            guard let global = try? Realm().objects(SalmonStatsShiftRealm.self).filter("start_time=%@", self.start_time).first else { return }
            
            // ボス討伐率のグラフ表示
            let player_kill_counts = results.lazy.map({ $0.player[0].boss_kill_counts })
            let other_kill_counts = results.lazy.map({ Array(zip($0.boss_kill_counts, $0.player[0].boss_kill_counts).map({ $0.0 - $0.1})) })
            let boss_appear_counts = results.lazy.map({ $0.boss_counts })
            var player_kill_counts_sum = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            var other_kill_counts_sum = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            var boss_appear_counts_sum = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            
            for kill_count in player_kill_counts {
                player_kill_counts_sum = Array(zip(player_kill_counts_sum, kill_count)).map({ $0.0 + $0.1 })
            }
            
            for kill_count in other_kill_counts {
                other_kill_counts_sum = Array(zip(other_kill_counts_sum, kill_count)).map({ $0.0 + $0.1 })
            }
            
            for appear_count in boss_appear_counts {
                boss_appear_counts_sum = Array(zip(boss_appear_counts_sum, appear_count)).map({ $0.0 + $0.1 })
            }
            
            // Zipして計算しやすくする
            let player_kill_ratio: [Double] = Array(zip(player_kill_counts_sum, boss_appear_counts_sum).map({ Double($0.0) / Double($0.1 == 0 ? 1 : $0.1) }))
            let other_kill_ratio: [Double] = Array(zip(other_kill_counts_sum, boss_appear_counts_sum).map({ Double($0.0) / Double($0.1 == 0 ? 1 : $0.1) / 3.0 }))
//            let global_kill_ratio: [Double] = Array(zip(global.boss_kill_counts, global.boss_counts).map({ Double($0.0) / Double($0.1 == 0 ? 1 : $0.1) / 4.0 }))
            let salmonia_kill_ratio = Array(zip(player_kill_ratio, other_kill_ratio).map({ max($0.0, $0.1)}))
            
            // ボス討伐率データの追加
            self.defeated = (
                data: [
                    DataPoint(player_kill_ratio, .blue),
                    DataPoint(other_kill_ratio, .red),
                    DataPoint(global_kill_ratio, .yellow)
                ],
                dimension: DataDimension(
                    ["Goldie", "Steelhead", "Flyfish", "Scrapper", "Steel Eel", "Stinger", "Maws", "Griller", "Drizzler"],
                    Array(zip(salmonia_kill_ratio, global_kill_ratio).map({ max($0.0, $0.1)}))
                )
            )
            // 金イクラ、赤イクラ、オオモノ討伐数、救助数、非救助数のグラフ
//            let player_overview: [Double] = [
//                Double(summary.my_ikura_total) / Double(summary.job_num),
//                Double(summary.my_golden_ikura_total) / Double(summary.job_num),
//                Double(summary.help_total) / Double(summary.job_num),
//                Double(summary.dead_total) / Double(summary.job_num)
//            ]
//
//            let other_overview: [Double] = [
//                Double(summary.team_ikura_total - summary.my_ikura_total) / Double(summary.job_num * 3),
//                Double(summary.team_golden_ikura_total - summary.my_golden_ikura_total) / Double(summary.job_num * 3),
//                Double(results.map({ $0.player.map({ $0.help_count}).reduce(0, +) }).reduce(0, +) - summary.help_total) / Double(summary.job_num * 3),
//                Double(results.map({ $0.player.map({ $0.dead_count}).reduce(0, +) }).reduce(0, +) - summary.dead_total) / Double(summary.job_num * 3)
//            ]
            
            let global_overview: [Double] = [
                Double(global.power_eggs) / Double(global.job_num * 4),
                Double(global.golden_eggs) / Double(global.job_num * 4),
                Double(global.rescue) / Double(global.job_num * 4),
                Double(global.rescue) / Double(global.job_num * 4),
            ]
            
            //            print(player_overview, other_overview, global_overview)
            
            let salmonia_overview = Array(zip(player_overview, other_overview).map({ max($0.0, $0.1)}))
            self.overview = (
                data: [
                    DataPoint(player_overview, .blue),
                    DataPoint(other_overview, .red),
                    DataPoint(global_overview, .yellow)
                ],
                dimension: DataDimension(
                    ["Power Egg", "Golden Egg", "Help", "Dead"],
                    Array(zip(salmonia_overview, global_overview).map({ max($0.0, $0.1)}))
                )
            )
        }
    }
}
