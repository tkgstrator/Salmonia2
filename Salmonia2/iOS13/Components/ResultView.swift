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
    @EnvironmentObject var result: CoopResultsRealm
    @State var isVisible: Bool = true
    @State var isEnable: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 5) {
                    ResultOverview
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(Range(1 ... result.wave.count)) { idx in
                            VStack(spacing: 0) {
                                ResultWaveView().environmentObject(result.wave[idx - 1])
                                SpecialUseView(special: result.getSP()[idx - 1])
                            }
                        }
                    }
                    VStack {
                        ForEach(Range(1...result.player.count)) { idx in
                            ResultPlayerView(isVisible: $isVisible).environmentObject(result.player[idx - 1])
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button)
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(Text("Detail"))
    }
    
    private var Button: some View {
        HStack {
            if isVisible {
                Image(systemName: "person.circle.fill").resizable().scaledToFit().frame(width: 30, height: 30)
                    .onTapGesture() {
                    isVisible.toggle()
                }
            } else {
                Image(systemName: "person.circle.fill").resizable().scaledToFit().frame(width: 30, height: 30)
                    .foregroundColor(.gray)
                    .onTapGesture() {
                    isVisible.toggle()
                }
            }
            Image(systemName: "info.circle.fill").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
                isEnable.toggle()
            }.sheet(isPresented: $isEnable) {
                ResultDetailView(isVisible: $isVisible).environmentObject(result.player)
            }
        }
    }
    
    private var ResultOverview: some View {
        ZStack {
            URLImage(url: URL(string: (StageType.init(stage_id: result.stage_id)?.image_url)!)!) { image in image.resizable().aspectRatio(contentMode: .fill).clipShape(RoundedRectangle(cornerRadius: 8.0)) }
            .frame(height: 160)
                .mask(URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/94aaee8dac73aa5f7cb0a31dfd21958d.png")!) { image in image.resizable() })
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack {
                        ZStack(alignment: .leading) {
                            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/e0ef914978d3318fa3ec2afbfa64c794.png")!) { image in image.renderingMode(.template).resizable().aspectRatio(contentMode: .fill) }
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
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable() }
                        .frame(width: 24, height: 24)
                    Text("x\(result.golden_eggs)")
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable() }
                        .frame(width: 24, height: 24)
                    Text("x\(result.power_eggs)")
                }.frame(maxWidth: .infinity)
            }
            .modifier(Splatfont(size: 20))
        }
        .frame(height: 160)
    }
    
    
    private struct ResultWaveView: View {
        @EnvironmentObject var wave: WaveDetailRealm
        
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
                Text(String(wave.golden_ikura_pop_num)).frame(height: 28).font(.custom("Splatfont2", size: 18))
            }
        }
    }
    
    private struct SpecialUseView: View {
        private var usage: [[Int]] = []
        
        init(special: [Int]) {
            usage = special.chunked(by: 4)
        }
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(usage.indices, id:\.self) { column in
                    HStack(spacing: 0) {
                        ForEach(usage[column].indices, id:\.self) { idx in
                            URLImage(url: FImage.getURL(usage[column][idx], 2)) { image in image.resizable() }
                                .frame(width: 28.75, height: 28.75)
                        }
                    }.frame(minWidth: 115, alignment: .leading)
                }
            }
            .frame(minWidth: 115, alignment: .leading)
        }
    }
    
    private struct ResultPlayerView: View {
        @EnvironmentObject var player: PlayerResultsRealm
        @Binding var isVisible: Bool
        
        var body: some View {
            NavigationLink(destination: SalmonStatsView().environmentObject(CrewInfoCore(player.nsaid!))) {
                VStack(spacing: 0) {
                    HStack {
                        Text(isVisible ? player.name.value : "-").font(.custom("Splatfont2", size: 20)).frame(width: 140)
                        Spacer()
                        Text("x\(player.boss_kill_counts.reduce(0, +))").foregroundColor(.blue).font(.custom("Splatfont2", size: 20))
                        Spacer()
                        URLImage(url: FImage.getURL(player.special_id, 2)) { image in image.resizable() }
                            .frame(width: 30, height: 30)
                        ForEach(player.weapon_list, id:\.self) { weapon in
                            URLImage(url: FImage.getURL(weapon, 1)) { image in image.resizable() }
                                .frame(width: 30, height: 30)
                        }
                    }.frame(height: 30)
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 20, height: 20)
                        Text(String(player.golden_ikura_num)).frame(width: 30)
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                            .frame(width: 20, height: 20)
                        Text(String(player.ikura_num)).frame(width: 48)
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!) { image in image.resizable()}
                            .frame(width: 50, height: 20)
                        Text(String(player.help_count)).frame(width: 30)
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!) { image in image.resizable()}
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
    
    private struct ResultDetailView: View {
        @EnvironmentObject var players: RealmSwift.List<PlayerResultsRealm>
        @Binding var isVisible: Bool
        
        var body: some View {
            List {
                ForEach(players, id:\.self) { player in
                    HStack {
                        VStack(spacing: 0) {
                            URLImage(url: URL(string: player.imageUri)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                                .frame(width: 60, height: 60)
                            if isVisible == true {
                                Text(player.name!).minimumScaleFactor(0.8).lineLimit(1)
                            } else {
                                Text(verbatim: "-").minimumScaleFactor(0.8).lineLimit(1)
                            }
                        }.frame(width: 90)
                        VStack(spacing: 0) {
                            HStack {
                                Geggs
                                Text("\(player.golden_ikura_num)")
                                Peggs
                                Text("\(player.ikura_num)")
                            }
                            HStack(spacing: 5) {
                                Boss3
                                Text("\(player.boss_kill_counts[0])")
                                Boss6
                                Text("\(player.boss_kill_counts[1])")
                                Boss9
                                Text("\(player.boss_kill_counts[2])")
                                Boss12
                                Text("\(player.boss_kill_counts[3])")
                            }
                            HStack(spacing: 5) {
                                Boss13
                                Text("\(player.boss_kill_counts[4])")
                                Boss14
                                Text("\(player.boss_kill_counts[5])")
                                Boss15
                                Text("\(player.boss_kill_counts[6])")
                                Boss16
                                Text("\(player.boss_kill_counts[7])")
                                Boss21
                                Text("\(player.boss_kill_counts[8])")
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }
            }.modifier(Splatfont(size: 15))
        }
        
        private var Geggs: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                .frame(width: 20, height: 20)
        }
        private var Peggs: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                .frame(width: 20, height: 20)
        }
        private var Boss3: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/9b2673de42f00d4fd836bd4684741505.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss6: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/337dde2c83705a75263aefdc15740f1c.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss9: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/631ea65c8cc2d9fd04f6c7458914d030.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss12: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/79d75f769115befab060b27401538402.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss13: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2466752cf11ef6326e2add430101bff6.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss14: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/862656b37d071e75ad31750c9e18ed15.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss15: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/367e6e1c33ab3ae2a1c857f4c75f017e.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss16: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/7f8e44737240e3caa52d6c4f457164d9.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
        private var Boss21: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/7ecdec1e23a3d0089b38038b0217827c.png")!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                .frame(width: 30, height: 30)
        }
    }
}
