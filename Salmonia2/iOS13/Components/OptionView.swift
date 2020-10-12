//
//  OptionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-09.
//

import SwiftUI
import Combine
import URLImage
import RealmSwift

struct OptionView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Options").foregroundColor(.cOrange).modifier(Splatfont(size: 20))
            WaveSearch
            CrewSearch
            CoopShift
        }
    }
    
    private var WaveSearch: some View {
        NavigationLink(destination: WaveCollectionView().environmentObject(WaveResultCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cGray)
                    Text("Wave Search").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var CoopShift: some View {
        NavigationLink(destination: PastCoopShiftView().environmentObject(CoopShiftCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cGray)
                    Text("Coop Shift Rotation").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var CrewSearch: some View {
        NavigationLink(destination: CrewSearchView().environmentObject(SalmoniaUserCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cGray)
                    Text("Crew Search").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
    }

    
}

private struct PastCoopShiftView: View {
    @EnvironmentObject var phase: CoopShiftCore
    
    @State var isVisible: Bool = false
    @State var isEnable: [Bool] = [true, true, true, true]
    @State var isPlayed: Bool = false
    private var types: [String] = ["Grizzco Rotation", "All Random Rotation", "One Random Rotation", "Normal Rotation"]
    
    init() {
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            ScrollViewReader { proxy in
                List {
                    VStack(spacing: 0) {
                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/a185b309f5cdad94942849070de04ce2.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fit).frame(width: 200) })
                        ZStack {
                            Image("CoopShedule").resizable().aspectRatio(contentMode: .fit).frame(height: 52)
                            Text("Shift Schedule").modifier(Splatfont(size: 18)).foregroundColor(.cOrange).padding(.top, 7)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    ForEach(phase.all.indices, id:\.self) { idx in
                        ZStack {
                            CoopShiftStack().environmentObject(phase.all[idx])
                            NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phase.all[idx].start_time)).environmentObject(SalmoniaUserCore())) {
                                EmptyView()
                            }.buttonStyle(PlainButtonStyle())
                        }
                    }
                }.onAppear() {
                    proxy.scrollTo((phase.all.count - 1), anchor: .center)
                }
            }
            .navigationBarTitle("Coop Shift Rotation")
            .navigationBarItems(trailing: filterButton)
        } else {
            List {
                VStack(spacing: 0) {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/a185b309f5cdad94942849070de04ce2.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fit).frame(width: 200) })
                    ZStack {
                        Image("CoopShedule").resizable().aspectRatio(contentMode: .fit).frame(height: 52)
                        Text("Shift Schedule").modifier(Splatfont(size: 18)).foregroundColor(.cOrange).padding(.top, 7)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.cDarkRed.edgesIgnoringSafeArea(.all))
                ForEach(phase.all.indices, id:\.self) { idx in
                    ZStack {
                        CoopShiftStack().environmentObject(phase.all[idx])
                        NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phase.all[idx].start_time)).environmentObject(SalmoniaUserCore())) {
                            EmptyView()
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .listRowBackground(Color.cDarkRed.edgesIgnoringSafeArea(.all))
            }
            .navigationBarTitle("Coop Shift Rotation")
            .navigationBarItems(trailing: filterButton)
        }
    }
    
    private var filterButton: some View {
        Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
            isVisible.toggle()
        }.sheet(isPresented: $isVisible) {
            CoopShiftFilter
        }
    }
    
    private var CoopShiftFilter: some View {
        List {
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
            phase.update(isEnable: isEnable, isPlayed: isPlayed)
        }
    }
    
    private struct CoopShiftStack: View {
        @EnvironmentObject var phases: CoopShiftCore
        @EnvironmentObject var phase: CoopShiftRealm
        
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
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 33, height: 22)})
                    Text(phase.start_time.year + " " + phase.start_time.time + " - " + phase.end_time.time).font(.custom("Splatfont2", size: 18)).minimumScaleFactor(0.7).lineLimit(1)
                }.frame(height: 22)
                Line().stroke(style: StrokeStyle(lineWidth: 3, dash: [8], dashPhase: 5)).frame(height: 2).foregroundColor(.cLightGray)
            }.frame(maxHeight: 25)
        }
        
        private var ShiftStageWeapon: some View {
            HStack {
                VStack(spacing: 5) {
                    URLImage(URL(string: (StageType(stage_id: phase.stage_id)?.image_url)!)!, content: {$0.image.resizable().frame(width: 112, height: 63)}).clipShape(RoundedRectangle(cornerRadius: 8.0))
                    Text((StageType.init(stage_id: phase.stage_id)?.stage_name!)!.localized).font(.custom("Splatfont2", size: 14))
                }.padding(.top, 10)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Supplied Weapons").font(.custom("Splatfont2", size: 16)).frame(height: 14)
                    HStack {
                        ForEach(phase.weapon_list, id:\.self) { weapon in
                            URLImage(WeaponType(weapon_id: weapon)!.image_url, content: {$0.image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)})
                        }
                        Group {
                            if phases.isUnlockWeapon && phase.weapon_list[3] == -1 {
                                URLImage(WeaponType(weapon_id: phase.rare_weapon)!.image_url, content: {$0.image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 45)})
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

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView()
    }
}
