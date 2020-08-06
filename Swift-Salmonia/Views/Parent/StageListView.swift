//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct StageListView: View {
    @ObservedObject var records = UserResultsCore()
    @State var stage_list: [Int] = [5000, 5001, 5002, 5003, 5004]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Stage Records")
                .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatoon1", size: 20))
            ForEach(stage_list.indices, id:\.self) { idx in
                HStack {
                    NavigationLink(destination: StageRecordsView(id: self.$stage_list[idx])) {
                        URLImage(URL(string: Stage(id: self.stage_list[idx]))!, content: {$0.image.resizable()})
                            .frame(width: 112, height: 63)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    //                    Spacer()
                    Text(Stage(name: self.stage_list[idx])).frame(maxWidth: .infinity)
                }.font(.custom("Splatoon1", size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct StageRecordsView: View {
    @ObservedObject var records = UserResultsCore()
    @Binding var stage_id: Int
    
    private var job_num: Int = 0
    private var win_ratio: Double = 0.0
    private var team_avg_power_eggs: Double = 0
    private var team_avg_golden_eggs: Double = 0
    private var my_avg_power_eggs: Double = 0
    private var my_avg_golden_eggs: Double = 0
    private var my_max_golden_eggs: Int?
    private var my_max_power_eggs: Int?
    private var team_max_power_eggs: Int?
    private var team_max_golden_eggs: Int?
    private var no_night_golden_eggs: Int?
    
    // メモリ消費しそうだなこれ...
    private var results: [CoopResultsRealm] = []
    
    init(id: Binding<Int>) {
        _stage_id = id
        results = records.results.all(id: stage_id)
        job_num = results.count
        win_ratio = (Double(results.filter({ $0.is_clear == true }).count) / Double(job_num)).round(digit: 4)
        team_max_power_eggs = results.map({ $0.power_eggs }).max()
        team_max_golden_eggs = results.map({ $0.golden_eggs }).max()
        team_avg_power_eggs = (Double(results.map({ $0.power_eggs }).reduce(0, +)) / Double(job_num)).round(digit: 2)
        team_avg_golden_eggs = (Double(results.map({ $0.golden_eggs }).reduce(0, +)) / Double(job_num)).round(digit: 2)
        my_max_power_eggs = results.map({ $0.player[0].ikura_num }).max()
        my_max_golden_eggs = results.map({ $0.player[0].golden_ikura_num }).max()
        my_avg_power_eggs = (Double(results.map({ $0.player[0].ikura_num }).reduce(0, +)) / Double(job_num)).round(digit: 2)
        my_avg_golden_eggs = (Double(results.map({ $0.player[0].golden_ikura_num }).reduce(0, +)) / Double(job_num)).round(digit: 2)
        no_night_golden_eggs = results.filter({ $0.wave.filter({ $0.event_type == "-" }).count == 3 }).map({ $0.golden_eggs }).max()
        print(no_night_golden_eggs)
    }
    
    var body: some View {
        ScrollView {
            // 概要表示
            ZStack {
                URLImage(URL(string: Stage(id: stage_id))!, content: { $0.image.resizable().aspectRatio(contentMode: .fill).opacity(0.5) }).frame(maxWidth: .infinity)
                HStack(alignment: .top) {
                    VStack {
                        Text("Jobs")
                        Text("\(job_num)")
                    }
                    VStack {
                        Text("Avg")
                        VStack(spacing: 0) {
                            HStack {
                                Text(String(team_avg_golden_eggs)).foregroundColor(.yellow)
                                Text("/")
                                Text(String(team_avg_power_eggs)).foregroundColor(.red)
                            }
                            HStack {
                                Text(String(my_avg_golden_eggs)).foregroundColor(.yellow)
                                Text("/")
                                Text(String(my_avg_power_eggs)).foregroundColor(.red)
                            }
                            .font(.custom("Splatoon1", size: 18))
                            .frame(height: 18)
                        }
                    }
                    VStack {
                        Text("Win")
                        Text(String(win_ratio))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
            }
            // まだ工事中のところ
            ZStack {
                // 背景のシャケ
                URLImage(URL(string: "https://www.nintendo.co.jp/switch/aab6a/assets/images/salmonrun_pic.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fill).opacity(0.5) }).frame(maxWidth: .infinity)
                // 実際のジャンプボタン
                VStack {
                    Text("Max")
                    VStack(spacing: 0) {
                        HStack {
                            Text(String(team_max_golden_eggs.value)).foregroundColor(.yellow)
                            Text("/")
                            Text(String(team_max_power_eggs.value)).foregroundColor(.red)
                        }
                        HStack {
                            Text(String(my_max_golden_eggs.value)).foregroundColor(.yellow)
                            Text("/")
                            Text(String(my_max_power_eggs.value)).foregroundColor(.red)
                        }
                        .font(.custom("Splatoon1", size: 18))
                        .frame(height: 18)
                    }
                    NavigationLink(destination: GoldenEggRecordsView()) {
                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fill) }).frame(width: 72, height: 72)
                    }.buttonStyle(PlainButtonStyle())
                }
                // 実際のジャンプボタン
            }
        }
        .font(.custom("Splatoon1", size: 22))
        .navigationBarTitle(Stage(name: stage_id))
    }
}

//struct StageRecordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StageRecordsView()
//    }
//}

struct StageRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
struct StageListView_Previews: PreviewProvider {
    static var previews: some View {
        StageListView()
    }
}
