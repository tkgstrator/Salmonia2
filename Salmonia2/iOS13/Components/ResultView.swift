//
//  ResultView.swift
//  Salmonia2
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct ResultView: View {
    @State var result: CoopResultsRealm
    @State var waves: RealmSwift.List<WaveDetailRealm>
    @State var players: RealmSwift.List<PlayerResultsRealm>
    @State var isVisible: Bool = true
//    @State var special: [[Int]] = []
    private var special: [[Int]] = []
    
    init(data: CoopResultsRealm) {
        _result = State(initialValue: data)
        _waves = State(initialValue: data.wave)
        _players = State(initialValue: data.player)
//        _special = State(initialValue: data.getSP())
        special = data.getSP()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 5) {
                    ResultOverview(result: $result)
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(Range(1...waves.count)) { idx in
                            VStack(spacing: 0) {
                                ResultWaveView(wave: $waves[idx - 1])
                                SpecialUseView(special: special[idx - 1])
                            }
                        }
                    }
                    VStack {
                        ForEach(Range(1...players.count)) { idx in
                            ResultPlayerView(player: $players[idx - 1], isVisible: $isVisible)
                        }
                    }
                }
            }
            .navigationBarItems(trailing:
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/skill/8a3f06a972689b094f762626ff36b3db8ee545b5.png")!,
                             content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                    ).frame(width: 30, height: 30).onTapGesture {
                        self.isVisible.toggle()
                    }
                }
            )
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(Text("Detail"))
    }
}

private struct SpecialUseView: View {
//    @Binding var special: [Int]
    private var usage: [[Int]] = []
    
    init(special: [Int]) {
        usage = special.chunked(by: 4)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(usage.indices, id:\.self) { column in
                HStack(spacing: 0) {
                    ForEach(usage[column].indices, id:\.self) { idx in
                        URLImage(FImage.getURL(usage[column][idx], 2), content: {$0.image.resizable()})
                            .frame(width: 28.75, height: 28.75)
                    }
                }.frame(minWidth: 115, alignment: .leading)
            }
        }
        .frame(minWidth: 115, alignment: .leading)
    }
}

private struct ResultOverview: View {
    @Binding var result: CoopResultsRealm
    
    var body: some View {
        ZStack {
            URLImage(FImage.getURL(result.stage_id, 0),
                     content: {$0.image.resizable().aspectRatio(contentMode: .fill).clipShape(RoundedRectangle(cornerRadius: 8.0))}
            )
            .frame(height: 160)
            .mask(
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/94aaee8dac73aa5f7cb0a31dfd21958d.png")!,
                         content: {$0.image.resizable()})
            )
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack {
                        ZStack(alignment: .leading) {
                            URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/e0ef914978d3318fa3ec2afbfa64c794.png")!,
                                     content: {$0.image.renderingMode(.template).resizable().aspectRatio(contentMode: .fill)})
                                .frame(width: 180, height: 30, alignment: .trailing).clipped().foregroundColor(.green)
                            Text(UnixTime.dateFromTimestamp(result.play_time)).modifier(Splatfont(size: 20)).padding(.horizontal, 10)
                        }
                    }
                }
                Group {
                    if self.result.danger_rate == 200 {
                        Text("Hazard Level MAX!!").modifier(Splatfont(size: 26))
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Hazard Level " + String(self.result.danger_rate) + "%").modifier(Splatfont(size: 26))
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                    }
                }
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 24, height: 24)
                    Text("x\(result.golden_eggs)")
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 24, height: 24)
                    Text("x\(result.power_eggs)")
                }.frame(maxWidth: .infinity)
            }
            .modifier(Splatfont(size: 20))
        }
        .frame(height: 160)
    }
}

private struct ResultWaveView: View {
    @Binding var wave: WaveDetailRealm
    
    var body: some View {
        VStack {
            VStack {
                Text("WAVE").foregroundColor(.black).font(.custom("Splatfont2", size: 16))
                HStack(spacing: 0) {
                    Text("\(wave.golden_ikura_num)")
                    Text("/")
                    Text("\(wave.quota_num)")
                }
                .frame(height: 36).frame(minWidth: 115)
                .foregroundColor(.white)
                .background(Color.init(UIColor.init("2A270B")))
                .font(.custom("Splatfont2", size: 28))
                Group {
                    Text(String(wave.ikura_num)).foregroundColor(.red).font(.custom("Splatfont2", size: 20))
                    Text(wave.water_level!.localized)
                    Text(wave.event_type!.localized)
                }.foregroundColor(.black).frame(height: 28).font(.custom("Splatfont2", size: 16))
            }
            .background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 3.0))
//            .mask(Image("board").resizable())
//            Text(String(wave.golden_ikura_pop_num)).frame(height: 28).font(.custom("Splatfont2", size: 18))
        }
    }
}

private struct ResultPlayerView: View {
    @Binding var player: PlayerResultsRealm
    @Binding var isVisible: Bool
    
    var body: some View {
        NavigationLink(destination: SalmonStatsView().environmentObject(CrewInfoCore(player.nsaid!))) {
            VStack(spacing: 0) {
                HStack {
                    Text(isVisible ? player.name.value : "-").font(.custom("Splatfont2", size: 22)).frame(width: 120)
                    Spacer()
                    Text("x\(player.boss_kill_counts.reduce(0, +))").foregroundColor(.blue).font(.custom("Splatfont2", size: 24))
                    Spacer()
                    URLImage(FImage.getURL(player.special_id, 2), content: {$0.image.resizable()})
                        .frame(width: 30, height: 30)
                    ForEach(player.weapon_list, id:\.self) { weapon in
                        URLImage(FImage.getURL(weapon, 1), content: {$0.image.resizable()})
                            .frame(width: 30, height: 30)
                    }
                }.frame(height: 30)
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text(String(player.golden_ikura_num)).frame(width: 30)
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text(String(player.ikura_num)).frame(width: 48)
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!, content: {$0.image.resizable()})
                        .frame(width: 50, height: 20)
                    Text(String(player.help_count)).frame(width: 30)
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!, content: {$0.image.resizable()})
                        .frame(width: 50, height: 20)
                    Text(String(player.dead_count)).frame(width: 30)
                }.frame(height: 24)
            }.font(.custom("Splatfont2", size: 18))
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear() {
            SalmonStats.getPlayerOverView(nsaid: player.nsaid!)
        }
    }
}

private struct ResultDefeatedView: View {
    
    var body: some View {
        Text("NOTHING")
        
    }
}
