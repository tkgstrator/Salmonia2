//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-28.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ShiftStatsView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @EnvironmentObject var stats: UserStatsCore
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                NavigationLink(destination: StatsChartView(start_time: stats.schedule!)) {
                    Text("Overview").font(.custom("Splatfont", size: 18))
                }
                Spacer()
            }) {
                ShiftStatsStack(title: "Job Num", value: stats.job_num)
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
                Text("Max").font(.custom("Splatfont", size: 18))
                Spacer()
            }){
                ShiftStatsStack(title: "Salmon Rate", value: stats.srpower[1]?.round(digit: 2))
                ShiftStatsStack(title: "Grade Point", value: stats.max_grade_point)
                if (stats.job_num != nil) {
                    NavigationLink(destination: ResultView().environmentObject(stats.max_results[0])) {
                        ShiftStatsStack(title: "Team Power Eggs", value: stats.max_team_power_eggs)
                    }
                    NavigationLink(destination: ResultView().environmentObject(stats.max_results[1])) {
                        ShiftStatsStack(title: "Team Golden Eggs", value: stats.max_team_golden_eggs)
                    }
                    NavigationLink(destination: ResultView().environmentObject(stats.max_results[2])) {
                        ShiftStatsStack(title: "Power Eggs", value: stats.max_my_power_eggs)
                    }
                    NavigationLink(destination: ResultView().environmentObject(stats.max_results[3])) {
                        ShiftStatsStack(title: "Golden Eggs", value: stats.max_my_golden_eggs)
                    }
                    NavigationLink(destination: ResultView().environmentObject(stats.max_results[4])) {
                    ShiftStatsStack(title: "Boss Defeated", value: stats.max_defeated)
                    }
                }
            }
            Section(header:HStack {
                Spacer()
                if !user.isUnlock[2] {
                    Text("Avg").font(.custom("Splatfont", size: 18))
                } else {
                    Text("Shinzo").font(.custom("Splatfont", size: 18))
                }
                Spacer()
            }) {
                ShiftStatsStack(title: "Clear Wave", value: stats.avg_clear_wave)
                ShiftStatsStack(title: "Crew Grade", value: stats.avg_crew_grade)
                ShiftStatsStack(title: "Team Power Eggs", value: stats.avg_team_power_eggs)
                ShiftStatsStack(title: "Team Golden Eggs", value: stats.avg_team_golden_eggs)
                ShiftStatsStack(title: "Power Eggs", value: stats.avg_my_power_eggs)
                ShiftStatsStack(title: "Golden Eggs", value: stats.avg_my_golden_eggs)
                ShiftStatsStack(title: "Boss Defeated", value: stats.avg_defeated)
                ShiftStatsStack(title: "Rescue Count", value: stats.avg_rescue)
                ShiftStatsStack(title: "Help Count", value: stats.avg_dead)
            }
            Section(header:HStack {
                Spacer()
                Text("Boss Defeated").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(BossType.allCases.indices, id:\.self) { idx in
                    ShiftStatsStack(title: (BossType.allCases[idx].boss_name!), value: stats.boss_defeated[idx].value)
                }
            }
        }.navigationBarTitle(UnixTime.dateFromTimestamp(stats.schedule!))
    }
}

struct StatsChartView: View {
    @EnvironmentObject var stats: UserStatsCore
//    @Binding var start_time: Int
    @State var isMode: Int = 0
        
    init(start_time: Int) {
        

    }
    
    var body: some View {
        Text("Under Construction")
            .onAppear() {
            }
    }
    
    func getShiftRecords(start_time: Int){
        let shift_id: String = UnixTime.dateToStartTime(start_time)
        AF.request("https://salmon-stats-api.yuki.games/api/schedules/\(shift_id)", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch (response.result) {
                case .success(let value):
                    // データベースに書き込む
                    let phase: CoopShiftRealm = realm.objects(CoopShiftRealm.self).filter("start_time=%@", start_time).first!
                    let json = JSON(value) // 全体のリザルトであることに注意
                    
//                    let
                    print(JSON(value)["records"])
                case .failure:
                    break
                }
            }
    
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
