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
    @Published var boss_defeated: [Double?] = [0, 0, 0, 0, 0, 0, 0, 0, 0]

    init(start_time: Int) {
        token = try? Realm().objects(CoopResultsRealm.self).observe { [self] _ in
            guard let results = try? Realm().objects(CoopResultsRealm.self).filter("start_time=%@", start_time) else { return }
            clear_ratio = Double(Double(results.filter("is_clear=%@", true).count) / Double(results.count)).round(digit: 4)
            let total_my_golden_eggs = Double(results.lazy.map({ $0.player[0].golden_ikura_num }).reduce(0, +))
            let total_my_power_eggs = Double(results.lazy.map({ $0.player[0].ikura_num }).reduce(0, +))
            let total_dead_count = Double(results.lazy.map({ $0.player[0].dead_count }).reduce(0, +))
            let total_help_count = Double(results.lazy.map({ $0.player[0].help_count }).reduce(0, +))
            let total_defeated = Double(results.map({ $0.player[0].boss_kill_counts.reduce(0, +) }).reduce(0, +))
                                    
            job_num = results.count
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
            avg_my_power_eggs = (total_my_golden_eggs / Double(job_num ?? 0)).round(digit: 2)
            avg_my_golden_eggs = (total_my_power_eggs / Double(job_num ?? 0)).round(digit: 2)
            avg_dead = Double(total_dead_count / Double(job_num ?? 0)).round(digit: 2)
            avg_rescue = Double(total_help_count / Double(job_num ?? 0)).round(digit: 2)
            avg_defeated = Double(total_defeated / Double(job_num ?? 0)).round(digit: 2)
            srpower = SRPower(results)
        }
    }
}
