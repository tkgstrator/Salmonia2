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
                ShiftStatsStack(title: "JOB NUM", value: stats.job_num)
                ShiftStatsStack(title: "SALMON RATE", value: stats.srpower[0]?.round(digit: 2))
                ShiftStatsStack(title: "CLEAR RATIO", value: stats.clear_ratio.value)
                ShiftStatsStack(title: "TOTAL POWER EGGS", value: stats.total_power_eggs)
                ShiftStatsStack(title: "TOTAL GOLDEN EGGS", value: stats.total_golden_eggs)
                ShiftStatsStack(title: "TOTAL GRIZZCO POINTS", value: stats.total_grizzco_points)
            }
            Section(header: HStack {
                Spacer()
                Text("MAX").font(.custom("Splatfont", size: 18))
                Spacer()
            }){
                ShiftStatsStack(title: "SALMON RATE", value: stats.srpower[1]?.round(digit: 2))
                ShiftStatsStack(title: "GRADE POINT", value: stats.max_grade_point)
                ShiftStatsStack(title: "TEAM POWER EGGS", value: stats.max_team_power_eggs)
                ShiftStatsStack(title: "TEAM GOLDEN EGGS", value: stats.max_team_golden_eggs)
                ShiftStatsStack(title: "POWER EGGS", value: stats.max_my_power_eggs)
                ShiftStatsStack(title: "GOLDEN EGGS", value: stats.max_my_golden_eggs)
                ShiftStatsStack(title: "DEFEATED", value: stats.max_defeated)
            }
            Section(header:HStack {
                Spacer()
                Text("AVERAGE").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ShiftStatsStack(title: "CLEAR WAVE", value: stats.avg_clear_wave)
                ShiftStatsStack(title: "CREW GRADE", value: stats.avg_crew_grade)
                ShiftStatsStack(title: "TEAM POWER EGGS", value: stats.avg_team_power_eggs)
                ShiftStatsStack(title: "TEAM GOLDEN EGGS", value: stats.avg_team_golden_eggs)
                ShiftStatsStack(title: "POWER EGGS", value: stats.avg_my_power_eggs)
                ShiftStatsStack(title: "GOLDEN EGGS", value: stats.avg_my_golden_eggs)
                ShiftStatsStack(title: "DEFEATED", value: stats.avg_defeated)
                ShiftStatsStack(title: "RESCUE", value: stats.avg_rescue)
                ShiftStatsStack(title: "DEAD", value: stats.avg_dead)
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
