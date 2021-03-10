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
import URLImage

struct ShiftStatsView: View {
    @EnvironmentObject var stats: UserStatsCore

    var body: some View {
        List {
            Overview
            MaxResult
            AvgResult
            BossDefeated
            GlobalRecords
            Advanced
        }
        .navigationTitle("TITLE_SHIFT_STATS")
    }
    
    var RecordButton: some View {
        NavigationLink(destination: StatsChartView(stats.schedule!)) {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable() }
                .frame(width: 30, height: 30)
        }
    }
    
    var Overview: some View {
        Section(header: Text("HEADER_OVERVIEW")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange))
        {
            CoopShiftStack(phase: stats.shift)
            // TODO: ここも課金情報直す
//            switch user.isPurchase {
//            case true:
//                AnyView(
//                    NavigationLink(destination: ResultCollectionView(core: UserResultCore(stats.schedule!))) {
//                        StatsColumn(title: "Job Num", value: stats.job_num)
//                    })
//            case false:
//                AnyView(
//                    StatsColumn(title: "Job Num", value: stats.job_num)
//                )
//            }
            Group {
                StatsColumn(title: "STATS_SRPOWER", value: stats.srpower[0]?.round)
                StatsColumn(title: "STATS_CLEAR_RATIO", value: stats.clear_ratio.per)
                StatsColumn(title: "STATS_TEAM_IKURA", value: stats.total_power_eggs)
                StatsColumn(title: "STATS_TEAM_GOLDEN_IKURA", value: stats.total_golden_eggs)
                StatsColumn(title: "STATS_IKURA_RATIO", value: stats.rate_power_eggs.per)
                StatsColumn(title: "STATS_GOLDEN_IKURA_RATIO", value: stats.rate_golden_eggs.per)
            }
            // TODO: ここはグラフ表示の方が絶対楽しい
            Group {
                StatsColumn(title: "STATS_SP_RATIO_BOM", value: stats.special[0].per)
                StatsColumn(title: "STATS_SP_RATIO_RAY", value: stats.special[1].per)
                StatsColumn(title: "STATS_SP_RATIO_JET", value: stats.special[2].per)
                StatsColumn(title: "STATS_SP_RATIO_SPL", value: stats.special[3].per)
            }
        }
//         課金しているユーザだけが個別のリザルトにジャンプできる
//        StatsColumn(title: "Salmon Rate", value: stats.srpower[0]?.round(digit: 2))
//        StatsColumn(title: "Clear Ratio", value: stats.clear_ratio.per)
//        StatsColumn(title: "Total Power Eggs", value: stats.total_power_eggs)
//        StatsColumn(title: "Total Golden Eggs", value: stats.total_golden_eggs)
//        StatsColumn(title: "Power Eggs Ratio", value: stats.rate_power_eggs.per)
//        StatsColumn(title: "Golden Eggs Ratio", value: stats.rate_golden_eggs.per)
//        Group {
//            StatsColumn(title: "Bomb Launcher", value: stats.special[0].per)
//            StatsColumn(title: "Sting Ray", value: stats.special[1].per)
//            StatsColumn(title: "Inkjet", value: stats.special[2].per)
//            StatsColumn(title: "Splashdown", value: stats.special[3].per)
//        }
    }
    
    var MaxResult: some View {
        Section(header: Text("HEADER_MAX_VALUE")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange))
        {
            StatsColumn(title: "STATS_SRPOWER", value: stats.srpower[1]?.round)
            StatsColumn(title: "STATS_GRADE_POINT", value: stats.max_grade_point)
            if (stats.job_num != nil) {
                NavigationLink(destination: ResultView(result: stats.max_results[0])) {
                    StatsColumn(title: "STATS_TEAM_IKURA", value: stats.max_team_power_eggs)
                }
                NavigationLink(destination: ResultView(result: stats.max_results[1])) {
                    StatsColumn(title: "STATS_TEAM_GOLDEN_IKURA", value: stats.max_team_golden_eggs)
                }
                NavigationLink(destination: ResultView(result: stats.max_results[2])) {
                    StatsColumn(title: "STATS_IKUEA_NUM", value: stats.max_my_power_eggs)
                }
                NavigationLink(destination: ResultView(result: stats.max_results[3])) {
                    StatsColumn(title: "STATS_GOLDEN_IKUEA_NUM", value: stats.max_my_golden_eggs)
                }
                NavigationLink(destination: ResultView(result: stats.max_results[4])) {
                    StatsColumn(title: "STATS_BOSS_DEFEATED", value: stats.max_defeated)
                }
            }
        }
    }
    
    var AvgResult: some View {
        Section(header: Text("HEADER_AVG_VALUE")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange))
        {
            StatsColumn(title: "STATS_CLEAR_WAVE", value: stats.avg_clear_wave?.round)
            StatsColumn(title: "STATS_CREW_GRADE", value: stats.avg_crew_grade?.round)
            StatsColumn(title: "STATS_TEAM_IKURA", value: stats.avg_team_power_eggs?.round)
            StatsColumn(title: "STATS_TEAM_GOLDEN_IKURA", value: stats.avg_team_golden_eggs?.round)
            StatsColumn(title: "STATS_IKURA_NUM", value: stats.avg_my_power_eggs?.round)
            StatsColumn(title: "STATS_GOLDEN_IKURA", value: stats.avg_my_golden_eggs?.round)
            StatsColumn(title: "STATS_BOSS_DEFEATED", value: stats.avg_defeated?.round)
            StatsColumn(title: "STATS_RESCUE_COUNT", value: stats.avg_rescue?.round)
            StatsColumn(title: "STATS_HELP_COUNT", value: stats.avg_dead?.round)
        }
    }
    
    var BossDefeated: some View {
        Section(header: Text("HEADER_BOSS_DEFEATED")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange))
        {
            ForEach(BossType.allCases.indices, id:\.self) { idx in
                StatsColumn(title: (BossType.allCases[idx].boss_name!), value: stats.boss_defeated[idx].per)
            }
        }
    }
    
    var GlobalRecords: some View {
        Section(header: Text("HEADER_GLOBAL_RECORDS")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange)) {
            Text("STATS_IKURA")
                .font(.custom("Splatfont2", size: 16))
            NavigationLink(destination: StatsChartView(stats.schedule!)) {
                Text("STATS_GOLDEN_IKURA")
                    .font(.custom("Splatfont2", size: 16))
            }
        }
    }
    
    var Advanced: some View {
        Section(header: Text("HEADER_ADVANCED")
                    .font(.custom("Splatfont2", size: 16))
                    .foregroundColor(.cOrange)) {
            NavigationLink(destination: WaveResultCollectionView(stats: stats)) {
                Text("TITLE_WAVE_ANALYSIS")
                    .font(.custom("Splatfont2", size: 16))
            }
            NavigationLink(destination: WeaponCollectionView(weapon_lists: stats.weapon_lists.chunked(by: 5))){
                Text("TITLE_WEAPON_ANALYSIS")
                    .font(.custom("Splatfont2", size: 16))
            }
        }
    }
    
    struct StatsColumn: View {
        @EnvironmentObject var rainbow: RainbowCore
        var title: String = ""
        var value: Any?
        
        var body: some View {
            HStack {
                Text(title.localized)
                    .font(.custom("Splatfont2", size: 16))
                    .rainbowAnimation(rainbow.shiftParam)
                Spacer()
                Text(value.value)
                    .font(.custom("Splatfont2", size: 16))
                    .rainbowAnimation(rainbow.shiftValue)
            }
        }
    }
}

struct StatsChartView: View {
    @EnvironmentObject var record: UserStatsCore
    
    init(_ start_time: Int) {
        // 読み込み時に新規レコードを保存する
        print("GET SHIFT RECORDS")
        getShiftRecords(start_time: start_time)
    }
    
    var body: some View {
        List {
            Section(header: Text("HEADER_TOTAL_EGGS").font(.custom("Splatfont2", size: 16)).foregroundColor(.yellow))
            {
                HStack {
                    Text("RECORD_ALL_EVENTS")
                    Spacer()
                    HStack {
                        Text("\(record.total[1].value)").frame(width: 55)
                        Text("(\(record.total[0].value))").frame(width: 55)
                    }
                }
                HStack {
                    Text("RECORD_NO_NIGHT")
                    Spacer()
                    HStack {
                        Text("\(record.no_night_total[1].value)").frame(width: 55)
                        Text("(\(record.no_night_total[0].value))").frame(width: 55)
                    }
                }
            }
            .font(.custom("Splatfont2", size: 16))
            ForEach(Range(0 ... 2)) { tide in
                Section(header: Text("\((WaveType.init(water_level: tide)?.water_name)!.localized)")
                            .font(.custom("Splatfont2", size: 16))
                            .foregroundColor(.orange))
                {
                    ForEach(Range(0 ... 6)) { event in
                        if record.global[tide][event] != nil {
                            HStack {
                                Text("\((EventType.init(event_id: event)?.event_name)!.localized)")
                                Spacer()
                                HStack {
                                    Text("\(record.personal[tide][event].value)").frame(width: 55)
                                    Text("(\(record.global[tide][event].value))").frame(width: 55)
                                }
                                
                            }
                            .font(.custom("Splatfont2", size: 16))
                        }
                    }
                }
            }
        }
        .navigationTitle("TITLE_GLOBAL_RECORDS")
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
