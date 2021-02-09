//
//  UserStatsCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-28.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class UserStatsCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var job_num: Int?
    @Published var schedule: Int?
    @Published var clear_ratio: Double?
    @Published var total_power_eggs: Int?
    @Published var total_golden_eggs: Int?
    @Published var srpower: [Double?] = [0.0, 0.0]
    @Published var rate_power_eggs: Double?
    @Published var rate_golden_eggs: Double?
    @Published var max_grade_point: Int?
    @Published var max_team_power_eggs: Int?
    @Published var max_team_golden_eggs: Int?
    @Published var max_my_power_eggs: Int?
    @Published var max_my_golden_eggs: Int?
    @Published var max_defeated: Int?
    @Published var avg_clear_wave: Double?
    @Published var avg_crew_grade: Double?
    @Published var avg_team_power_eggs: Double?
    @Published var avg_team_golden_eggs: Double?
    @Published var avg_my_power_eggs: Double?
    @Published var avg_my_golden_eggs: Double?
    @Published var avg_defeated: Double?
    @Published var avg_rescue: Double?
    @Published var avg_dead: Double?
    @Published var boss_defeated: [Double?] = [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    @Published var max_results: [CoopResultsRealm] = []
    @Published var special: [Double?] = [nil, nil, nil, nil]
    @Published var isRareWeapon: Bool = true
    @Published var salmonids: [(count: Int, result: CoopResultsRealm)] = []
    @Published var player_total: [Int?] = [nil, nil, nil, nil]
    @Published var total_eggs: [Int?] = [nil, nil]
    
    init(start_time: Int) {
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
            let nsaids: [String] = Array(user.account.filter("isActive=true").map({ $0.nsaid }))
            isRareWeapon = user.isUnlock[1] // クマブキアンロック情報を取得
            schedule = start_time

            // リザルト一覧からシフトを指定して取得
            let results = realm.objects(CoopResultsRealm.self).filter("start_time=%@ and nsaid IN %@", start_time, nsaids)
            let player = realm.objects(PlayerResultsRealm.self).filter("ANY result.start_time=%@ and nsaid IN %@", start_time, nsaids)
            // バイト回数を取得
            job_num = results.count == 0 ? nil : results.count
            // バイト回数がnilでなければ以下の計算を行う
            
            if job_num != nil {
                // オオモノ出現数を計算
                var boss_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
                var boss_kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
                for count in results.map({ $0.boss_counts }) {
                    boss_counts = Array(zip(boss_counts, count)).map({ $0.0 + $0.1 })
                }
                for count in player.map({ $0.boss_kill_counts }){
                    boss_kill_counts = Array(zip(boss_kill_counts, count)).map({ $0.0 + $0.1 })
                }
                boss_defeated = zip(boss_kill_counts, boss_counts).map({ Double($0.0) / Double($0.1) })
                
                // 合計を求める
                total_power_eggs = results.sum(ofProperty: "power_eggs")
                total_golden_eggs = results.sum(ofProperty: "golden_eggs")

                // 平均を求める
                avg_team_power_eggs = results.average(ofProperty: "power_eggs")
                avg_team_golden_eggs = results.average(ofProperty: "golden_eggs")
                avg_my_power_eggs = player.average(ofProperty: "ikura_num")
                avg_my_golden_eggs = player.average(ofProperty: "golden_ikura_num")
                avg_dead = player.average(ofProperty: "dead_count")
                avg_rescue = player.average(ofProperty: "help_count")
                avg_defeated = Array(player.compactMap({ $0.boss_kill_counts.sum() })).average()
                avg_clear_wave = Array(results.map({ ($0.failure_wave.value ?? 4) - 1 })).average()
                avg_crew_grade = results.map({ 20 * $0.danger_rate + Double($0.grade_point_delta.value ?? 0) - Double($0.grade_point.value ?? 0) - 1600.0}).lazy.reduce(0.0, +) / Double((job_num ?? 0) * 3)
                
                // 最大を求める
                max_team_power_eggs = results.max(ofProperty: "power_eggs")
                max_team_golden_eggs = results.max(ofProperty: "golden_eggs")
                max_my_power_eggs = player.max(ofProperty: "ikura_num")
                max_my_golden_eggs = player.max(ofProperty: "golden_ikura_num")
                max_grade_point = results.max(ofProperty: "grade_point")
                max_defeated = player.map({ $0.boss_kill_counts.sum() }).max()
                
                // 割合を計算する
                special = [
                    Double(player.filter("special_id=%@", 2).count) / Double(job_num!),
                    Double(player.filter("special_id=%@", 7).count) / Double(job_num!),
                    Double(player.filter("special_id=%@", 8).count) / Double(job_num!),
                    Double(player.filter("special_id=%@", 9).count) / Double(job_num!),
                ]
                clear_ratio = Double(results.filter("is_clear=true").count) / Double(job_num!)
                rate_power_eggs = player.sum(ofProperty: "ikura_num") / results.sum(ofProperty: "power_eggs")
                rate_golden_eggs = player.sum(ofProperty: "golden_ikura_num") / results.sum(ofProperty: "golden_eggs")

                max_results = [
                    results.filter("power_eggs=%@", max_team_power_eggs).first!,
                    results.filter("golden_eggs=%@", max_team_golden_eggs).first!,
                    player.filter("ikura_num=%@", max_my_power_eggs).first!.result.first!,
                    player.filter("golden_ikura_num=%@", max_my_golden_eggs).first!.result.first!,
                    player.filter({ $0.boss_kill_counts.sum() == max_defeated }).first!.result.first!
                ]

                srpower = SRPower(results)
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

// 毎回計算させる必要がないデータはここで計算する
extension Array where Element == Int {
    func sum() -> Int {
        return self.reduce(0, +)
    }
    
    func average() -> Double {
        return Double(self.reduce(0, +)) / Double(self.count)
    }
    
    // 出現回数をカウントして出現率を返す
    func count(_ value: Int) -> Int {
        return self.filter({ $0 == value }).count
    }
}

// 何してるかよくわからない関数
extension UserStatsCore {
    var stats_golden_eggs: [Double] {
        var golden_eggs: [Double] = []
        let start_times = Array(Set(realm.objects(CoopResultsRealm.self).map({ $0.start_time }))).sorted()
        
        for start_time in start_times {
            let avg: Double? = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time).average(ofProperty: "golden_eggs")
            golden_eggs.append(avg!)
        }
        return golden_eggs
    }
    
    var stats_power_eggs: [Double] {
        var power_eggs: [Double] = []
        let start_times = Array(Set(realm.objects(CoopResultsRealm.self).map({ $0.start_time }))).sorted()
        
        for start_time in start_times {
            let avg: Double? = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time).average(ofProperty: "power_eggs")
            power_eggs.append(avg!)
        }
        return power_eggs
    }
    
    var shift: CoopShiftRealm {
        return realm.objects(CoopShiftRealm.self).filter("start_time=%@", self.schedule as Any).first!
    }
}
