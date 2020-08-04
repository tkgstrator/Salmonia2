//
//  ShiftStatsVIew.swift
//  
//
//  Created by devonly on 2020-08-03.
//

import SwiftUI
import SwiftyJSON

struct ShiftStatsView: View {
    @Binding var start_time: Int
    @ObservedObject var stats: UserStatsCore
    

    init(start_time: Binding<Int>) {
        _start_time = start_time
        _stats = ObservedObject(initialValue: UserStatsCore(start_time: start_time))
    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("OVERVIEW").font(.custom("Splatfont2", size: 20))
                Spacer()
            }) {
                StatsStackView(title: "JOB NUM", value: stats.job_num)
                StatsStackView(title: "ESTIMATE SR POWER", value: nil)
                StatsStackView(title: "CURRENT SR POWER", value: nil)
                StatsStackView(title: "CREAR RATIO", value: stats.clear_ratio.value)
                StatsStackView(title: "TOTAL POWER EGGS", value: stats.total_power_eggs)
                StatsStackView(title: "TOTAL GOLDEN EGGS", value: stats.total_golden_eggs)
                StatsStackView(title: "TOTAL GRIZZCO POINTS", value: stats.total_grizzco_points)
            }
            Section(header: HStack {
                Spacer()
                Text("MAX").font(.custom("Splatfont2", size: 20))
                Spacer()
            }){
                StatsStackView(title: "GRADE POINT", value: stats.max_grade_point)
                StatsStackView(title: "TEAM POWER EGGS", value: stats.max_team_power_eggs)
                StatsStackView(title: "TEAM GOLDEN EGGS", value: stats.max_team_golden_eggs)
                StatsStackView(title: "POWER EGGS", value: stats.max_my_power_eggs)
                StatsStackView(title: "GOLDEN EGGS", value: stats.max_my_golden_eggs)
                StatsStackView(title: "DEFEATED", value: stats.max_defeated)
            }
            Section(header:HStack {
                Spacer()
                Text("AVERAGE").font(.custom("Splatfont2", size: 20))
                Spacer()
            }) {
                Text("STATS STACK")
                StatsStackView(title: "CLEAR WAVE", value: stats.avg_clear_wave)
                StatsStackView(title: "CREW GRADE", value: stats.avg_crew_grade)
                StatsStackView(title: "TEAM POWER EGGS", value: stats.avg_team_power_eggs)
                StatsStackView(title: "TEAM GOLDEN EGGS", value: stats.avg_team_golden_eggs)
                StatsStackView(title: "POWER EGGS", value: stats.avg_my_power_eggs)
                StatsStackView(title: "GOLDEN EGGS", value: stats.avg_my_golden_eggs)
                StatsStackView(title: "DEFEATED", value: stats.avg_defeated)
                StatsStackView(title: "RESCUE", value: stats.avg_rescue)
                StatsStackView(title: "DEAD", value: stats.avg_dead)
            }
        }.navigationBarTitle("\(start_time)")
    }
}

// Int?とDouble?を同時に一つのBindingで受け取る方法がわからず
private struct StatsStackView: View {
    private var value: String
    private var title: String

    init(title: String, value: Any?) {
        self.value = value.value
        self.title = title
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
    
}

//struct ShiftStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShiftStatsView()
//    }
//}
