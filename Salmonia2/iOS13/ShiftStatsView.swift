//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-28.
//

import SwiftUI

struct ShiftStatsView: View {
    
    @EnvironmentObject var stats: UserStatsCore
    //    @Binding var start_time: Int
    
    //    init(start_time: Binding<Int>) {
    //        _start_time = start_time
    //    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("OVERVIEW").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ShiftStatsStack(title: "Job num", value: stats.job_num)
                ShiftStatsStack(title: "Salmon Rate", value: stats.srpower[0]?.round(digit: 2))
                ShiftStatsStack(title: "Clear Ratio", value: stats.clear_ratio.value)
                ShiftStatsStack(title: "Total Power Eggs", value: stats.total_power_eggs)
                ShiftStatsStack(title: "Total Golden Eggs", value: stats.total_golden_eggs)
                ShiftStatsStack(title: "Bomb Launcher", value: stats.special[0].value)
                ShiftStatsStack(title: "Sting Ray", value: stats.special[1].value)
                ShiftStatsStack(title: "Inkjet", value: stats.special[2].value)
                ShiftStatsStack(title: "Splashdown", value: stats.special[3].value)
            }
            Section(header: HStack {
                Spacer()
                Text("MAX").font(.custom("Splatfont", size: 18))
                Spacer()
            }){
                ShiftStatsStack(title: "Salmon Rate", value: stats.srpower[1]?.round(digit: 2))
                ShiftStatsStack(title: "Grade Point", value: stats.max_grade_point)
                if (stats.job_num != 0) {
                    NavigationLink(destination: ResultView(data: stats.max_results[0])) {
                        ShiftStatsStack(title: "Team Power Eggs", value: stats.max_team_power_eggs)
                    }
                    NavigationLink(destination: ResultView(data: stats.max_results[1])) {
                        ShiftStatsStack(title: "Team Golden Eggs", value: stats.max_team_golden_eggs)
                    }
                    NavigationLink(destination: ResultView(data: stats.max_results[2])) {
                        ShiftStatsStack(title: "Power Eggs", value: stats.max_my_power_eggs)
                    }
                    NavigationLink(destination: ResultView(data: stats.max_results[3])) {
                        ShiftStatsStack(title: "Golden Eggs", value: stats.max_my_golden_eggs)
                    }
                    NavigationLink(destination: ResultView(data: stats.max_results[4])) {
                    ShiftStatsStack(title: "Boss Defeated", value: stats.max_defeated)
                    }
                }
            }
            Section(header:HStack {
                Spacer()
                Text("AVERAGE").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ShiftStatsStack(title: "Clear Wave", value: stats.avg_clear_wave)
                ShiftStatsStack(title: "Crew Grade", value: stats.avg_crew_grade)
                ShiftStatsStack(title: "Team Power Eggs", value: stats.avg_team_power_eggs)
                ShiftStatsStack(title: "Team Golden Eggs", value: stats.avg_team_golden_eggs)
                ShiftStatsStack(title: "Ppwer Eggs", value: stats.avg_my_power_eggs)
                ShiftStatsStack(title: "Golden Eggs", value: stats.avg_my_golden_eggs)
                ShiftStatsStack(title: "Boss Defeated", value: stats.avg_defeated)
                ShiftStatsStack(title: "Rescue", value: stats.avg_rescue)
                ShiftStatsStack(title: "Dead", value: stats.avg_dead)
            }
        }.navigationBarTitle("\(stats.max_my_golden_eggs ?? 0)")
    }
}

private struct ShiftStatsStack: View {
    private var value: String
    private var title: String
    
    init(title: String, value: Any?) {
        self.value = value.value
        self.title = title
    }
    
    var body: some View {
        HStack {
            Text(title.localized)
            Spacer()
            Text(value)
        }
        .font(.custom("Splatfont2", size: 20))
    }
}

//struct ShiftStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShiftStatsView()
//    }
//}
