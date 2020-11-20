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
    @Published var total_grizzco_points: Int?
    @Published var srpower: [Double?] = [0.0, 0.0]
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
    
    init(start_time: Int) {
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            schedule = start_time
            let _nsaids = realm.objects(UserInfoRealm.self)
            let nsaids: [String] = Array(_nsaids.map({ $0.nsaid }))
            let results = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time)
            let players = realm.objects(PlayerResultsRealm.self).filter("ANY result.start_time=%@ AND nsaid IN %@", start_time, nsaids)

            let total_my_golden_eggs = Double(results.lazy.map({ $0.player[0].golden_ikura_num }).reduce(0, +))
            let total_my_power_eggs = Double(results.lazy.map({ $0.player[0].ikura_num }).reduce(0, +))
            let total_dead_count = Double(results.lazy.map({ $0.player[0].dead_count }).reduce(0, +))
            let total_help_count = Double(results.lazy.map({ $0.player[0].help_count }).reduce(0, +))
            let total_defeated = Double(results.map({ $0.player[0].boss_kill_counts.reduce(0, +) }).reduce(0, +))
            
            let _boss_counts = results.map({ $0.boss_counts })
            let _boss_kill_counts = players.map({ $0.boss_kill_counts })
            
            var boss_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            var boss_kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            for _count in _boss_counts {
                boss_counts = Array(zip(boss_counts, _count)).map({ $0.0 + $0.1 })
            }
            for _count in _boss_kill_counts {
                boss_kill_counts = Array(zip(boss_kill_counts, _count)).map({ $0.0 + $0.1 })
            }
            
            for idx in Range(0 ... 8) {
                if (boss_counts[idx] != 0) {
                    boss_defeated[idx] = (Double(boss_kill_counts[idx]) / Double(boss_counts[idx])).round(digit: 4)
                }
            }

            job_num = results.count == 0 ? nil : results.count

            if job_num != nil {
                clear_ratio = Double(Double(results.filter("is_clear=%@", true).count) / Double(job_num ?? 0)).round(digit: 4)
                total_golden_eggs = results.sum(ofProperty: "golden_eggs")
                total_power_eggs = results.sum(ofProperty: "power_eggs")
                max_grade_point = results.max(ofProperty: "grade_point")
                max_team_golden_eggs = results.max(ofProperty: "golden_eggs")
                max_team_power_eggs = results.max(ofProperty: "power_eggs")
                max_my_power_eggs = results.lazy.map({ $0.player[0].ikura_num }).max()
                max_my_golden_eggs = results.lazy.map({ $0.player[0].golden_ikura_num }).max()
                max_defeated = results.lazy.map({ $0.player[0].boss_kill_counts.reduce(0, +) }).max()
                avg_clear_wave = Double(Double(results.map({ ($0.failure_wave.value ?? 4) - 1}).reduce(0, +)) / Double(results.count)).round(digit: 2)
                avg_crew_grade = (results.map({ 20 * $0.danger_rate + Double($0.grade_point_delta.value ?? 0) - Double($0.grade_point.value ?? 0) - 1600.0}).lazy.reduce(0.0, +) / Double((job_num ?? 0) * 3)).round(digit: 2)
                avg_team_golden_eggs = Double(Double(total_golden_eggs ?? 0) / Double(job_num ?? 0)).round(digit: 2)
                avg_team_power_eggs = Double(Double(total_power_eggs ?? 0) / Double(job_num ?? 0)).round(digit: 2)
                avg_my_power_eggs = (total_my_power_eggs / Double(job_num ?? 0)).round(digit: 2)
                avg_my_golden_eggs = (total_my_golden_eggs / Double(job_num ?? 0)).round(digit: 2)
                avg_dead = Double(total_dead_count / Double(job_num ?? 0)).round(digit: 2)
                avg_rescue = Double(total_help_count / Double(job_num ?? 0)).round(digit: 2)
                avg_defeated = Double(total_defeated / Double(job_num ?? 0)).round(digit: 2)

                for (idx, sp) in [2, 7, 8, 9].enumerated() {
                    if job_num != nil {
                        special[idx] = (Double(results.filter({ $0.player[0].special_id == sp}).count) / Double(job_num!)).round(digit: 4)
                    }
                }

                max_results = []
                max_results.append(results.filter("power_eggs=%@",  max_team_power_eggs).first!)
                max_results.append(results.filter("golden_eggs=%@", max_team_golden_eggs).first!)
                max_results.append(players.filter("ikura_num=%@", max_my_power_eggs).first!.result.first!)
                max_results.append(players.filter("golden_ikura_num=%@", max_my_golden_eggs).first!.result.first!)
                max_results.append(players.filter({ $0.boss_kill_counts.reduce(0, +) == max_defeated }).first!.result.first!)
            }
            srpower = SRPower(results)
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

// 毎回計算させる必要がないデータはここで計算する
extension UserStatsCore {
    var stats_golden_eggs: [Double] {
        var golden_eggs: [Double] = []
        let start_times = Array(Set(realm.objects(CoopResultsRealm.self).map({ $0.start_time }))).sorted()
        
        for start_time in start_times {
            let avg: Double? = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time).average(ofProperty: "golden_eggs")
            golden_eggs.append(avg!)
        }
        print(golden_eggs)
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
}
