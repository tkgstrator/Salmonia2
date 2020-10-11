//
//  WaveCollectionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-08-29.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct WaveCollectionView: View {
    @EnvironmentObject var core: WaveResultCore
    
    @State var isVisible: Bool = false
    @State var event_type: [Int] = [0, 1, 2, 3, 4, 5, 6]
    @State var water_level: [Int] = [0, 1, 2]
    @State var isTide: [Bool] = [true, true, true]
    @State var isEvent: [Bool] = [true, true, true, true, true, true, true]
    @State var isStage: [Bool] = [true, true, true, true, true]
    
    var body: some View {
        Group {
            HStack {
                Text("Found: \(core.waves.count)")
            }
            .font(.custom("Splatfont", size: 16))
            .frame(height: 10)
            List {
                ForEach(core.waves.indices, id:\.self) { idx in
                    NavigationLink(destination: ResultView(data: core.waves[idx].result.first!)) {
                        WaveStack(data: core.waves[idx])
                    }
                }
            }
        }
        .navigationBarTitle("Waves")
        .navigationBarItems( trailing: filterButton)
    }

    var filterButton: some View {
        HStack {
            Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
                isVisible.toggle()
            }.sheet(isPresented: $isVisible) {
                WaveFilterView
            }
        }
    }
    
    var WaveFilterView: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("Stage").font(.custom("Splatfont", size: 22)).foregroundColor(.yellow)
                Spacer()
            }) {
                ForEach(StageType.allCases.indices, id:\.self) { idx in
                    Toggle(isOn: $isStage[idx]) {
                        Text(StageType.init(stage_id: 5000 + idx)!.stage_name!.localized)
                    }
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Tide").font(.custom("Splatfont", size: 22)).foregroundColor(.yellow)
                Spacer()
            }) {
                ForEach(Range(0 ... 2)) { idx in
                    Toggle(isOn: $isTide[idx]) {
                        Text(WaveType.init(water_level: idx)!.water_name!.localized)
                    }
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Event").font(.custom("Splatfont", size: 22)).foregroundColor(.yellow)
                Spacer()
            }) {
                ForEach(Range(0 ... 6)) { idx in
                    Toggle(isOn: self.$isEvent[idx]) {
                        Text(EventType.init(event_id: idx)!.event_name!.localized)
                    }
                }
            }
        }
        .font(.custom("Splatfont", size: 18))
        .onDisappear() {
            // 画面を閉じるときにアップデートしてみよう
            var water_level: [Int] = []
            var event_type: [Int] = []
            var stage_id: [Int] = []
            
            for (idx, tide) in self.isTide.enumerated() {
                if tide { water_level.append(idx) }
            }
            for (idx, event) in self.isEvent.enumerated() {
                if event { event_type.append(idx) }
            }
            for (idx, stage) in self.isStage.enumerated() {
                if stage { stage_id.append(idx + 5000) }
            }
            core.update(event_type, water_level, stage_id)
        }
    }
}


private struct WaveStack: View {
    private var stage_name: String?
    private var event_type: String?
    private var water_level: String?
    private var ikura_num: Int
    private var golden_ikura_num: Int
    private var golden_ikura_pop_num: Int
    private var collected_ratio: Double
    
    init(data: WaveDetailRealm) {
        stage_name = StageType.init(stage_id: data.result.first!.stage_id)!.stage_name
        event_type = data.event_type.value
        water_level = data.water_level.value
        ikura_num = data.ikura_num
        golden_ikura_num = data.golden_ikura_num
        golden_ikura_pop_num = data.golden_ikura_pop_num
        collected_ratio = (Double(golden_ikura_num) / Double(golden_ikura_pop_num) * 100).round(digit: 2)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(String(collected_ratio) + "%")
                    Text(stage_name.value.localized)
                }
                .font(.custom("Splatfont", size: 14)).foregroundColor(.yellow)
                HStack {
                    Text(water_level.value.localized)
                    Text(event_type.value.localized)
                }
            }
            .font(.custom("Splatfont", size: 16))
            // ブキとか？
            // 金イクラ数とかの情報（イカリング2準拠スタイル）
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(golden_ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                }
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                }
            }.frame(width: 80).font(.custom("Splatfont2", size: 16))
        }
    }
}

