//
//  PlayerStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine

struct StatsColumn: View {
    private var title = ""
    private var value = ""
    
    init(title: String, value: Any?) {
        self.title = title
        self.value = value.string
    }
    
    var body: some View {
        HStack {
            Text(self.title).font(.custom("Splatfont2", size: 20))
            Spacer()
            Text(self.value).font(.custom("Splatfont2", size: 20))
        }.frame(height: 30)
    }
}


struct PlayerStatsView: View {
    @ObservedObject var stats = Stats()
    
    init() {
        if #available(iOS 14.0, *) {
            // iOS 14 doesn't have extra separators below the list by default.
        } else {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
        }
        
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HStack {
                    Spacer()
                    Text("OVERVIEW").font(.custom("Splatfont2", size: 20))
                    Spacer()
                }) {
                    StatsColumn(title: "JOB NUM", value: stats.job_num)
                    StatsColumn(title: "ESTIMATE SR POWER", value: nil)
                    StatsColumn(title: "CURRENT SR POWER", value: nil)
                    StatsColumn(title: "CREAR RATIO", value: stats.clear_ratio)
                    StatsColumn(title: "TOTAL POWER EGGS", value: stats.total_power_eggs)
                    StatsColumn(title: "TOTAL GOLDEN EGGS", value: stats.total_golden_eggs)
                    StatsColumn(title: "TOTAL GRIZZCO POINTS", value: stats.total_grizzco_points)
                }
                Section(header: HStack {
                    Spacer()
                    Text("MAX").font(.custom("Splatfont2", size: 20))
                    Spacer()
                }){
                    StatsColumn(title: "GRADE POINT", value: stats.max_grade_point)
                    StatsColumn(title: "TEAM POWER EGGS", value: stats.max_team_power_eggs)
                    StatsColumn(title: "TEAM GOLDEN EGGS", value: stats.max_team_golden_eggs)
                    StatsColumn(title: "POWER EGGS", value: stats.max_my_power_eggs)
                    StatsColumn(title: "GOLDEN EGGS", value: stats.max_my_golden_eggs)
                    StatsColumn(title: "DEFEATED", value: stats.max_defeated)
                }
                Section(header:HStack {
                    Spacer()
                    Text("AVERAGE").font(.custom("Splatfont2", size: 20))
                    Spacer()
                }) {
                    StatsColumn(title: "CLEAR WAVE", value: stats.avg_clear_wave)
                    StatsColumn(title: "CREW GRADE", value: stats.avg_crew_grade)
                    StatsColumn(title: "TEAM POWER EGGS", value: stats.avg_team_power_eggs)
                    StatsColumn(title: "TEAM GOLDEN EGGS", value: stats.avg_team_golden_eggs)
                    StatsColumn(title: "POWER EGGS", value: stats.avg_my_power_eggs)
                    StatsColumn(title: "GOLDEN EGGS", value: stats.avg_my_golden_eggs)
                    StatsColumn(title: "DEFEATED", value: stats.avg_defeated)
                    StatsColumn(title: "RESCUE", value: stats.avg_rescue)
                    StatsColumn(title: "DEAD", value: stats.avg_dead)
                }
            }
            .listStyle(DefaultListStyle())
            .environment(\.defaultMinListRowHeight, 30)
            .navigationBarTitle(Text("Stats"))
        }
    }
}

class Stats: ObservableObject {
    @Published var job_num: Int?
    @Published var clear_ratio: Double?
    @Published var total_power_eggs: Int?
    @Published var total_golden_eggs: Int?
    @Published var total_grizzco_points: Int?
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
    
    private var token: NotificationToken? // 変更を伝えるトークン
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
    //    public let summary = try? Realm().objects(ShiftResultsRealm.self).sorted(byKeyPath: "start_time", ascending: false).first // おまけ
    
    init() {
        // リアルタイム更新のためのメソッド
        token = realm?.observe{ _ in
            // realmに変更があったときだけ呼ばれる
            // publishedの値を変更する（これによってViewの再レンダリングが行われる
            guard let start_time = self.realm?.sorted(byKeyPath: "start_time", ascending: false).first?.start_time else { return }
            guard let results = self.realm?.filter("start_time=%@", start_time) else { return }
            guard let summary = try? Realm().objects(ShiftResultsRealm.self).sorted(byKeyPath: "start_time", ascending: false).first else { return }
            self.job_num = summary.job_num
            self.clear_ratio = Double(Double(results.filter("job_result_is_clear=%@", true).count) / Double(summary.job_num)).round(digit: 4)
            self.total_golden_eggs = summary.team_golden_ikura_total
            self.total_power_eggs = summary.team_ikura_total
            self.total_grizzco_points = summary.kuma_point_total
            self.max_grade_point = results.max(ofProperty: "grade_point")
            self.max_team_golden_eggs = results.max(ofProperty: "golden_eggs")
            self.max_team_power_eggs = results.max(ofProperty: "power_eggs")
            self.max_my_power_eggs = results.map({ $0.player[0].ikura_num }).max()
            self.max_my_golden_eggs = results.map({ $0.player[0].golden_ikura_num }).max()
            self.max_defeated = results.map({ $0.player[0].defeat.reduce(0, +) }).max()
            self.avg_clear_wave = Double(Double(results.map({ ($0.job_result_failure_wave.value ?? 4) - 1}).reduce(0, +)) / Double(summary.job_num)).round(digit: 2)
            self.avg_crew_grade = (results.map({ 20 * $0.danger_rate + Double($0.grade_point_delta) - Double($0.grade_point) - 1600.0}).reduce(0.0, +) / Double(summary.job_num * 3)).round(digit: 2)
            self.avg_team_golden_eggs = Double(Double(summary.team_golden_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_team_power_eggs = Double(Double(summary.team_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_my_golden_eggs = Double(Double(summary.my_golden_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_my_power_eggs = Double(Double(summary.my_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_dead = Double(Double(summary.dead_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_rescue = Double(Double(summary.help_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_defeated = Double((Double(results.map({ $0.player[0].defeat.reduce(0, +) }).reduce(0, +)) / Double(summary.job_num))).round(digit: 2)
            
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    //    guard let realm = try? Realm() else { return }
    //    guard let start_time = realm.objects(CoopResultsRealm.self).sorted(byKeyPath: "start_time", ascending: false).first?.start_time else { return }
    //    let results = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time)
    //    guard let summary = realm.objects(ShiftResultsRealm.self).filter("start_time=%@", start_time).first else { return }
    //
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatsView()
    }
}
