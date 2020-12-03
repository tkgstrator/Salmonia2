//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-28.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import RealmSwift

struct ShiftStatsView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @EnvironmentObject var stats: UserStatsCore
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                NavigationLink(destination: StatsChartView(stats.schedule!).environmentObject(ShiftRecordCore(stats.schedule!))) {
                    Text("Overview").modifier(Splatfont(size: 22))
                }
                Spacer()
            }) {
                ShiftStatsStack(title: "Job Num", value: stats.job_num)
                ShiftStatsStack(title: "Salmon Rate", value: stats.srpower[0]?.round(digit: 2))
                ShiftStatsStack(title: "Clear Ratio", value: stats.clear_ratio.per)
                ShiftStatsStack(title: "Total Power Eggs", value: stats.total_power_eggs)
                ShiftStatsStack(title: "Total Golden Eggs", value: stats.total_golden_eggs)
                ShiftStatsStack(title: "Bomb Launcher", value: stats.special[0].per)
                ShiftStatsStack(title: "Sting Ray", value: stats.special[1].per)
                ShiftStatsStack(title: "Inkjet", value: stats.special[2].per)
                ShiftStatsStack(title: "Splashdown", value: stats.special[3].per)
            }
            Section(header: HStack {
                Spacer()
                Text("Max").modifier(Splatfont(size: 22))
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
                if !user.isUnlock[3] {
                    Text("Avg").modifier(Splatfont(size: 22))
                } else {
                    Text("Shinzo").modifier(Splatfont(size: 22))
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
                Text("Boss Defeated").modifier(Splatfont(size: 22))
                Spacer()
            }) {
                ForEach(BossType.allCases.indices, id:\.self) { idx in
                    ShiftStatsStack(title: (BossType.allCases[idx].boss_name!), value: stats.boss_defeated[idx].per)
                }
            }
        }.navigationBarTitle(UnixTime.dateFromTimestamp(stats.schedule!))
    }
}

struct StatsChartView: View {
    @EnvironmentObject var record: ShiftRecordCore

    init(_ start_time: Int) {
        getShiftRecords(start_time: start_time)
    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("Total")
                    .modifier(Splatfont(size: 22))
                    .foregroundColor(.yellow)
                Spacer()
            }) {
                HStack {
                    Text("All")
                    Spacer()
                    HStack {
                        Text("\(record.total[1].value)").frame(width: 55)
                        Text("(\(record.total[0].value))").frame(width: 55)
                    }
                    .font(.custom("Splatfont2", size: 20))
                }
                HStack {
                    Text("No Night Event")
                    Spacer()
                    HStack {
                        Text("\(record.no_night_total[1].value)").frame(width: 55)
                        Text("(\(record.no_night_total[0].value))").frame(width: 55)
                    }
                    .font(.custom("Splatfont2", size: 20))
                }
            }
            ForEach(Range(0 ... 2)) { tide in
                Section(header: HStack {
                    Spacer()
                    Text("\((WaveType.init(water_level: tide)?.water_name)!.localized)")
                        .modifier(Splatfont(size: 22))
                        .foregroundColor(.orange)
                    Spacer()
                }) {
                    ForEach(Range(0 ... 6)) { event in
                        if record.global[tide][event] != nil {
                            //                                NavigationLink(destination: ResultView().environmentObject(record.salmon_id[tide][event]!)) {
                            HStack {
                                Text("\((EventType.init(event_id: event)?.event_name)!.localized)")
                                Spacer()
                                HStack {
                                    Text("\(record.personal[tide][event].value)").frame(width: 55)
                                    Text("(\(record.global[tide][event].value))").frame(width: 55)
                                }
                                .font(.custom("Splatfont2", size: 20))
                            }
                            //                                }
                        }
                    }
                }
            }
        }
        .modifier(Splatfont2(size: 20))
        .navigationBarTitle("Global Records")
    }
    
    func getShiftRecords(start_time: Int) {
        let events: [Int: Int] = [
            0: 0,
            1: 6,
            2: 5,
            3: 2,
            4: 3,
            5: 4,
            6: 1
        ]
        
        let tides: [Int: Int] = [
            1: 0,
            2: 1,
            3: 2
        ]
        
        let shift_id: String = UnixTime.dateToStartTime(start_time)
        AF.request("https://salmon-stats-api.yuki.games/api/schedules/\(shift_id)", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch (response.result) {
                case .success(let value):
                    // データベースに書き込む
//                    let records: RealmSwift.List<WaveRecordsRealm> = realm.objects(CoopShiftRealm.self).filter("start_time=%@", start_time).first!.records
                    let json = JSON(value)["records"] // 全体のリザルトであることに注意
                    
                    var waves: [JSON] = []
                    waves.append(json["totals"]["golden_eggs"])
                    waves.append(json["no_night_totals"]["golden_eggs"])
                    for (_, wave) in json["wave_records"]["golden_eggs"] {
                        waves.append(wave)
                    }
                    
                    autoreleasepool {
                        realm.beginWrite()
                        for (idx, wave) in waves.enumerated() {
                            let job_id = wave["id"].intValue
                            let golden_ikura_num: Int = wave["golden_eggs"].intValue
                            
                            let water_level: Int = wave["water_id"].int != nil ? tides[wave["water_id"].intValue]! : idx == 0 ? -1 : -2
                            let event_type: Int = wave["event_id"].int != nil ? events[wave["event_id"].intValue]! : idx == 0 ? -1 : -2
                            
                            realm.create(WaveRecordsRealm.self, value: WaveRecordsRealm(job_id, start_time, water_level, event_type, golden_ikura_num), update: .all)
                        }
                        try? realm.commitWrite()
                    }
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
                .modifier(Splatfont2(size: 20))
            Spacer()
            Text(value)
                .font(.custom("Splatfont2", size: 20))
        }
    }
}

//struct ShiftStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShiftStatsView()
//    }
//}
