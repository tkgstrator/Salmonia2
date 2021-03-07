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
        List {
            ForEach(core.waves.indices, id:\.self) { idx in
                NavigationLink(destination: ResultView(result: core.waves[idx].result.first!)) {
                    WaveStack(wave: core.waves[idx])
                }
            }
        }
        .navigationTitle("TITLE_WAVE_RESULTS")
        .navigationBarItems( trailing: filterButton)
    }
    
    var filterButton: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .Modifier()
                .onTapGesture() { isVisible.toggle()}
                .sheet(isPresented: $isVisible) {
                WaveFilterView
            }
        }
    }
    
    var WaveFilterView: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("Stage")
                    .modifier(Splatfont2(size: 18))
                    .foregroundColor(.yellow)
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
                Text("Tide")
                    .modifier(Splatfont2(size: 18))
                    .foregroundColor(.yellow)
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
                Text("Event")
                    .modifier(Splatfont2(size: 18))
                    .foregroundColor(.yellow)
                Spacer()
            }) {
                ForEach(Range(0 ... 6)) { idx in
                    Toggle(isOn: self.$isEvent[idx]) {
                        Text(EventType.init(event_id: idx)!.event_name!.localized)
                    }
                }
            }
        }
        .modifier(Splatfont2(size: 16))
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
    
    struct WaveStack: View {
        @ObservedObject var wave: WaveDetailRealm

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(wave.water_level!.localized)
                        Text((StageType.init(stage_id: wave.result.first!.stage_id)?.stage_name!.localized)!)
                    }
                    .modifier(Splatfont2(size: 14))
                    .frame(height: 14)
                    .foregroundColor(.yellow)
                    Text(wave.event_type!.localized)
                }
                .modifier(Splatfont2(size: 16))
                // ブキとか？
                // 金イクラ数とかの情報（イカリング2準拠スタイル）
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(wave.golden_ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                    }
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(wave.ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                    }
                }
                .frame(width: 55)
                .modifier(Splatfont2(size: 14))
            }
            
        }
    }
}
