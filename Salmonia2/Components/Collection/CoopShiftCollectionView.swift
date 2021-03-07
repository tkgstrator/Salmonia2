//
//  CoopShiftCollection.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-21.
//

import SwiftUI
import URLImage
import RealmSwift

struct CoopShiftCollectionView: View {
    @ObservedObject var phase = CoopShiftCore()
    @State var isVisible: Bool = false
    @State var isTime: [Bool] = [true, true, true]
    @State var isEnable: [Bool] = [true, true, true, true, true, true, true, true]
    @State var isPlayed: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                VStack(spacing: 0) {
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/a185b309f5cdad94942849070de04ce2.png")!) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 200) }
                    ZStack {
                        Image("CoopShedule").resizable().aspectRatio(contentMode: .fit).frame(height: 52)
                        Text("TITLE_SHIFT_SCHEDULE").modifier(Splatfont(size: 18)).foregroundColor(.cOrange).padding(.top, 7)
                    }
                }
                .frame(maxWidth: .infinity)
                ForEach(phase.all.indices, id:\.self) { idx in
                    ZStack {
                        NavigationLink(destination: ShiftStatsView()
                                        .environmentObject(UserStatsCore(start_time: phase.all[idx].start_time))
                        ) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        CoopShiftStack(phase: phase.all[idx])
                    }
                }
            }
            .onAppear() {
                proxy.scrollTo((phase.all.count - phase.now.count - 1), anchor: .center)
            }
        }
        .navigationTitle("TITLE_SHIFT_SCHEDULE")
        .navigationBarItems(trailing: FilterButton)
    }
    
    var FilterButton: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .Modifier()
                .onTapGesture() {
                    isVisible.toggle()
                }.sheet(isPresented: $isVisible) {
                    CoopFilterView(phase: phase, isEnable: $isEnable, isPlayed: $isPlayed, isTime: $isTime)
                }
        }
    }
}

private struct CoopFilterView: View {
    @ObservedObject var phase: CoopShiftCore
    @Binding var isEnable: [Bool]
    @Binding var isPlayed: Bool
    @Binding var isTime: [Bool]
    var types: [String] = ["Grizzco Rotation", "All Random Rotation", "One Random Rotation", "Normal Rotation"]
    
    var body: some View {
        List {
            Section(header: Text("HEADER_COOP_ROTAION").modifier(Splatfont2(size: 18)).foregroundColor(.cOrange)) {
                ForEach(Range(0...3)) { idx in
                    Toggle(isOn: $isEnable[idx]) {
                        Text((types[idx]).localized)
                    }
                }
                Section(header: Text("HEADER_OPTION").modifier(Splatfont2(size: 18)).foregroundColor(.cOrange)) {
                    Toggle(isOn: $isPlayed) {
                        Text("Only played")
                    }
                }
            }
            .modifier(Splatfont2(size: 16))
            .onDisappear() {
                phase.update(isEnable: isEnable, isPlayed: isPlayed, isTime: isTime)
            }
        }
    }
}

struct CoopShiftStack: View {
    @ObservedObject var phase: CoopShiftRealm
    @EnvironmentObject var shift: CoopShiftCore
    @EnvironmentObject var unlock: UnlockCore
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                ShiftInfoOverview
                ShiftStageWeapon
            }
        }
        .frame(height: 120)
        .modifier(Splatfont2(size: 18))
    }
    
    private var BackgroundMask: some View {
        ZStack {
            Color.black.opacity(0.8)
            Image("CoopMask").resizable(resizingMode: .tile).renderingMode(.template).foregroundColor(.white).opacity(0.8)
        }
    }
    
    private var ShiftInfoOverview: some View {
        HStack {
            Text(phase.start_time.year + " " + phase.start_time.time + " - " + phase.end_time.time)
                .font(.custom("Splatfont2", size: 16))
            Spacer()
        }
    }
    
    private var ShiftStageWeapon: some View {
        HStack {
            VStack(spacing: 0) {
                URLImage(url: URL(string: (StageType(stage_id: phase.stage_id)?.image_url)!)!) { image in image.resizable().frame(width: 112, height: 63) }.clipShape(RoundedRectangle(cornerRadius: 8.0))
                Text((StageType.init(stage_id: phase.stage_id)?.stage_name!)!.localized)
                    .modifier(Splatfont2(size: 14))
                    .padding(.bottom, 8)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("SUPPLIED_WEAPONS")
                    .modifier(Splatfont2(size: 16))
                    .frame(height: 14)
                HStack {
                    ForEach(phase.weapon_list, id:\.self) { weapon in
                        URLImage(url: WeaponType(weapon_id: weapon)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)}
                    }
                    Group {
                        if unlock.rareWeapon && phase.weapon_list[3] == -1 {
                            URLImage(url: WeaponType(weapon_id: phase.rare_weapon)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)}
                        }
                    }
                }
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
            }
            //                .frame(maxHeight: 81)
        }
        .frame(maxHeight: 81)
    }
}

extension Int {
    var time: String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
    
    var year: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
}
