//
//  CoopShiftCollection.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-21.
//

import SwiftUI
import URLImage
import RealmSwift

struct PastCoopShiftView: View {
    @ObservedObject var phase = CoopShiftCore()
    @State var isVisible: Bool = false
    @State var isEnable: [Bool] = [true, true, true, true]
    @State var isPlayed: Bool = false
    // private var types: [String] = ["Grizzco Rotation", "All Random Rotation", "One Random Rotation", "Normal Rotation"]
    
//    init() {
//        UITableView.appearance().tableFooterView = UIView()
//        UITableView.appearance().separatorStyle = .none
//    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollViewReader { proxy in
                List {
                    VStack(spacing: 0) {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/a185b309f5cdad94942849070de04ce2.png")!) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 200) }
                        ZStack {
                            Image("CoopShedule").resizable().aspectRatio(contentMode: .fit).frame(height: 52)
                            Text("Shift Schedule").modifier(Splatfont(size: 18)).foregroundColor(.cOrange).padding(.top, 7)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    ForEach(phase.all.indices, id:\.self) { idx in
                        ZStack {
                            NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phase.all[idx].start_time)).environmentObject(SalmoniaUserCore())) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            CoopShiftStack(phase: phase.all[idx], isRareWeapon: $phase.isUnlockWeapon)
                        }
                    }
                }
//                  .onAppear() {
//                    proxy.scrollTo((phase.all.count - 1), anchor: .center)
//                }
            }
            .navigationBarTitle("Coop Shift Rotation", displayMode: .large)
            .navigationBarItems(trailing: FilterButton)
        } else {
            List {
                VStack(spacing: 0) {
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/a185b309f5cdad94942849070de04ce2.png")!) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 200) }
                    ZStack {
                        Image("CoopShedule").resizable().aspectRatio(contentMode: .fit).frame(height: 52)
                        Text("Shift Schedule").modifier(Splatfont(size: 18)).foregroundColor(.cOrange).padding(.top, 7)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.cDarkRed.edgesIgnoringSafeArea(.all))
                ForEach(phase.all.indices, id:\.self) { idx in
                    ZStack {
                        NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phase.all[idx].start_time)).environmentObject(SalmoniaUserCore())) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        CoopShiftStack(phase: phase.all[idx], isRareWeapon: $phase.isUnlockWeapon)
                    }
                }
                .listRowBackground(Color.cDarkRed.edgesIgnoringSafeArea(.all))
            }
            .navigationBarTitle("Coop Shift Rotation")
            .navigationBarItems(trailing: FilterButton)
        }
    }
    
    private var FilterButton: some View {
        HStack {
            Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
                isVisible.toggle()
            }.sheet(isPresented: $isVisible) {
                CoopFilterView(phase: phase, isEnable: $isEnable, isPlayed: $isPlayed)
            }
        }
    }
    
    private struct CoopFilterView: View {
        @ObservedObject var phase: CoopShiftCore
        @Binding var isEnable: [Bool]
        @Binding var isPlayed: Bool
        var types: [String] = ["Grizzco Rotation", "All Random Rotation", "One Random Rotation", "Normal Rotation"]
        
        var body: some View {
            List {
//                Text("Construction")
                Section(header: HStack {
                    Spacer()
                    Text("Rotation").font(.custom("Splatfont", size: 22)).foregroundColor(.cOrange)
                    Spacer()
                }) {
                    ForEach(Range(0...3)) { idx in
                        Toggle(isOn: $isEnable[idx]) {
                            Text((types[idx]).localized)
                        }
                    }
                }
                Section(header: HStack {
                    Spacer()
                    Text("Options").font(.custom("Splatfont", size: 22)).foregroundColor(.cOrange)
                    Spacer()
                }) {
                    Toggle(isOn: $isPlayed) {
                        Text("Only played")
                    }
                }
            }
            .modifier(Splatfont(size: 18))
            .onDisappear() {
                print("DISAPPEAR")
                phase.update(isEnable: isEnable, isPlayed: isPlayed)
            }
        }
    }
    
    struct CoopShiftStack: View {
        @ObservedObject var phase: CoopShiftRealm
        @Binding var isRareWeapon: Bool
        
        var body: some View {
            GeometryReader { geometry in
                VStack(spacing: 10) {
                    ShiftInfoOverview
                    ShiftStageWeapon
                }
            }
            .frame(height: 120)
            .padding(.all, 8)
            .background(BackgroundMask)
            .mask(RoundedRectangle(cornerRadius: 12.0))
            .font(.custom("Splatfont2", size: 18))
        }
        
        private var BackgroundMask: some View {
            ZStack {
                Color.black.opacity(0.8)
                Image("CoopMask").resizable(resizingMode: .tile).renderingMode(.template).foregroundColor(.white).opacity(0.8)
                
            }
        }
        
        private var ShiftInfoOverview: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!) { image in image.resizable().frame(width: 33, height: 22)}
                    Text(phase.start_time.year + " " + phase.start_time.time + " - " + phase.end_time.time).font(.custom("Splatfont2", size: 18)).minimumScaleFactor(0.7).lineLimit(1)
                }.frame(height: 22)
                Line().stroke(style: StrokeStyle(lineWidth: 3, dash: [8], dashPhase: 5)).frame(height: 2).foregroundColor(.cLightGray)
            }.frame(maxHeight: 25)
        }
        
        private var ShiftStageWeapon: some View {
            HStack {
                VStack(spacing: 5) {
                    URLImage(url: URL(string: (StageType(stage_id: phase.stage_id)?.image_url)!)!) { image in image.resizable().frame(width: 112, height: 63) }.clipShape(RoundedRectangle(cornerRadius: 8.0))
                    Text((StageType.init(stage_id: phase.stage_id)?.stage_name!)!.localized).font(.custom("Splatfont2", size: 14))
                }.padding(.top, 10)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Supplied Weapons").font(.custom("Splatfont2", size: 16)).frame(height: 14)
                    HStack {
                        ForEach(phase.weapon_list, id:\.self) { weapon in
                            URLImage(url: WeaponType(weapon_id: weapon)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)}
                        }
                        Group {
                            if isRareWeapon && phase.weapon_list[3] == -1 {
                                URLImage(url: WeaponType(weapon_id: phase.rare_weapon)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)}
                            }
                        }
                    }
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity)
                }
                //                .frame(maxHeight: 81)
            }
            .frame(maxHeight: 81)
        }
        
        struct Line: Shape {
            func path(in rect: CGRect) -> Path {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: rect.width, y:0))
                return path
            }
        }
    }
}

private extension Int {
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
