//
//  ShiftRotationView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import URLImage

let response: JSON = try! JSON(data: NSData(contentsOfFile: Bundle.main.path(forResource: "formated_future_shifts", ofType:"json")!) as Data)
let lastid = response.filter({ $0.1["EndDateTime"].intValue < Int(Date().timeIntervalSince1970)}).last!.0

// 直近のシフト三件を表示するビュー
struct FutureShiftView: View {
    @State var current_time: Int = Int(Date().timeIntervalSince1970)
    @State var phases: [JSON] = response.filter({ Int($0.0)! >= Int(lastid)! }).map({ $0.1 }).prefix(3).map({ $0 })
    @State var start_time: [Int] = []
    
    init () {
        let start_time = phases.map({ $0["StartDateTime"].intValue })
        _start_time = State(initialValue: start_time)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Shift Schedule")
                .foregroundColor(.orange)
                .font(.custom("Splatfont", size: 20))
            ForEach(phases.indices) { idx in
                NavigationLink(destination: SalmoniaShiftView(start_time: self.$start_time[idx])) {
                    ShiftStack(phase: self.$phases[idx])
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// シフトのスタック表示
private struct ShiftStack: View {
    @Binding var phase: JSON
    @ObservedObject var user = UserInfoCore()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 27, height: 18)})
                Text(Unixtime(interval: phase["StartDateTime"].intValue)).frame(height: 18)
                Text(verbatim: "-").frame(height: 18)
                Text(Unixtime(interval: phase["EndDateTime"].intValue)).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(URL(string: ImageURL.stage(phase["StageID"].intValue))!, content: {$0.image.resizable().frame(width: 112, height: 63)
                }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
                HStack {
                    ForEach((phase["WeaponSets"].arrayObject as! [Int]).indices, id:\.self) { idx in
                        URLImage(URL(string: ImageURL.weapon(self.phase["WeaponSets"][idx].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    }
                    // 緑ランダムの場合は最後にクマブキ表示
                    if user.is_unlock && phase["WeaponSets"][3].intValue == -1 {
                        URLImage(URL(string: ImageURL.weapon(self.phase["RareWeaponID"].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    }
                }.frame(maxWidth: .infinity)
            }.frame(height: 63)
        }.frame(height: 100)
            .font(.custom("Splatfont2", size: 18))
    }
}

// 各シフトのStatsが表示される
struct SalmoniaShiftView: View {
    @Binding var start_time: Int
    @State var isVisible: Bool = true
    var body: some View {
        Group {
            if isVisible {
                SalmoniaShiftStats(start_time: $start_time).tag("stats")
            } else {
                SalmoniaShiftRecord(start_time: $start_time).tag("record")
            }
        }
        .navigationBarTitle("\(start_time)")
        .navigationBarItems(trailing:
            URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                     content: {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
            ).frame(width: 30, height: 30).onTapGesture {
                self.isVisible.toggle()
            }
        )
    }
}

private struct SalmoniaShiftRecord: View {
    @Binding var start_time: Int
    @State var global: SalmonStatsRecordFormat = SalmonStatsRecordFormat()
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("High Tide").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(global.records[2].indices, id:\.self) { idx in
                    SalmoniaShiftRecordStack(record: self.$global.records[2][idx])
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Normal Tide").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(global.records[1].indices, id:\.self) { idx in
                    SalmoniaShiftRecordStack(record: self.$global.records[1][idx])
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Low Tide").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(global.records[0].indices, id:\.self) { idx in
                    SalmoniaShiftRecordStack(record: self.$global.records[0][idx])
                }
            }
        }
        .onAppear() {
            SalmonStats.getShiftRecord(start_time: self.start_time) { response in
                self.global = response
            }
        }
    }
}

private struct SalmoniaShiftStats: View {
    @Binding var start_time: Int
    @ObservedObject var stats: UserStatsCore
    @State var salmonstats: SalmonStatsFormat = SalmonStatsFormat()
    private let boss: [String] = ["Goldie", "Steelhead", "Flyfish", "Scrapper", "Steel Eel", "Stinger", "Maws", "Griller", "Drizzler"]

    init(start_time: Binding<Int>) {
        _start_time = start_time
        _stats = ObservedObject(initialValue: UserStatsCore(start_time: start_time))
    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("OVERVIEW").font(.custom("Splatfont", size: 18))
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
                Text("MAX").font(.custom("Splatfont", size: 18))
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
                Text("AVERAGE").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
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
            Section(header:HStack {
                Spacer()
                Text("BOSS").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(salmonstats.other_defeated.indices, id:\.self) { idx in
                    HStack {
                        Text("\(self.boss[idx])")
                        Spacer()
                        ProgressView(value: [self.stats.boss_defeated[idx] ?? 0, self.salmonstats.other_defeated[idx]])
                    }
                }
            }
        }.onAppear() {
            SalmonStats.getPlayerShiftStatsDetail(nsaid: "3f89c3791c43ea57", start_time: SSTime(time: self.start_time)) { response in
//                print(response)
                self.salmonstats = SalmonStats.encodeStats(response)
//                print(self.salmonstats.other_defeated)
            }
        }
//        .padding(.horizontal, 10)
        .font(.custom("Splatfont2", size: 20))
//        .navigationBarTitle("\(start_time)")
    }
}

private struct SalmoniaShiftRecordStack: View {
    @Binding var record: (id: Int, cr: Int, pr: Int?, players: [String])
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\((SplatNet2.getEventName(record.id)).localized)").font(.custom("Splatfont", size: 20)).frame(width: 180)
                Spacer()
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fill) }).frame(width: 24, height: 24)
                Text("x\(record.pr.value)").frame(width: 40).foregroundColor(.yellow)
                Text("x\(record.cr)").frame(width: 40)
            }
            HStack {
                ForEach(Range(1...record.players.count - 1), id:\.self) { idx in
                    Text("\(self.record.players[idx])").foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .font(.custom("Splatfont", size: 16))
        }.font(.custom("Splatfont", size: 18))
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
            Text(title.localized)
            Spacer()
            Text(value)
        }
    }
    
}

// 設定から見る今後の全シフト情報
struct CompleteShiftView: View {
    @State var current_time: Int = Int(Date().timeIntervalSince1970)
    @State var phases: [JSON] = response.filter({ Int($0.0)! >= Int(lastid)! }).map({ $0.1 }).map({ $0 })
    @State var start_time: [Int] = []
    
    init () {
        let start_time = phases.map({ $0["StartDateTime"].intValue })
        _start_time = State(initialValue: start_time)
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        List {
            ForEach(phases.indices) { idx in
                ShiftStack(phase: self.$phases[idx])
            }
        }.navigationBarTitle("Future Rotation")
    }
}


struct FutureShiftView_Previews: PreviewProvider {
    static var previews: some View {
        FutureShiftView()
    }
}
