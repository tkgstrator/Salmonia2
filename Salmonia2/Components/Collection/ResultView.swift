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
    @ObservedObject var result: CoopResultsRealm
    @State var maxWidth: CGFloat = UIScreen.main.bounds.size.width >= 360 ? 120 : 100
    @State var isVisible: Bool = true
    @State var isEnable: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                ResultOverview
                ResultWaveView
                ResultPlayerView
            }
        }
        .navigationBarItems(trailing: UIButton)
        .navigationBarTitle(Text("Detail"))
    }

    var UIButton: some View {
        HStack {
            Button(action: { isVisible.toggle() }) { Image(systemName: "person.circle.fill").Modifier(isVisible) }
            Button(action: { isEnable.toggle() }) { Image(systemName: "info.circle.fill").Modifier(isEnable) }
        }.sheet(isPresented: $isEnable) {
            ResultDetailView(isVisible: $isVisible).environmentObject(result)
        }
    }
    
    var ResultOverview: some View {
        ZStack {
            URLImage(url: URL(string: (StageType.init(stage_id: result.stage_id)?.image_url)!)!) { image in image.resizable().aspectRatio(contentMode: .fill).clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                .frame(height: 120)
                .mask(URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/94aaee8dac73aa5f7cb0a31dfd21958d.png")!) { image in image.resizable() })
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack {
                        ZStack(alignment: .leading) {
                            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/e0ef914978d3318fa3ec2afbfa64c794.png")!) { image in image.renderingMode(.template).resizable().aspectRatio(contentMode: .fill) }
                                .frame(width: 144, height: 24, alignment: .trailing).clipped().foregroundColor(.green)
                            Text(UnixTime.dateFromTimestamp(result.play_time))
                                .font(.custom("Splatfont", size: 16))
                                .padding(.horizontal, 10)
                                .shadow(color: .black, radius: 0, x: 1, y: 1)
                        }
                    }
                }
                Group {
                    if self.result.danger_rate == 200 {
                        Text("Hazard Level MAX!!")
                            .modifier(Splatfont(size: 20))
                            .shadow(color: .black, radius: 0, x: 1, y: 1)
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Hazard Level " + String(self.result.danger_rate) + "%")
                            .modifier(Splatfont(size: 20))
                            .shadow(color: .black, radius: 0, x: 1, y: 1)
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                    }
                }
                HStack {
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable() }
                        .frame(width: 24, height: 24)
                    Text("x\(result.golden_eggs)")
                        .shadow(color: .black, radius: 0, x: 1, y: 1)
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable() }
                        .frame(width: 24, height: 24)
                    Text("x\(result.power_eggs)")
                        .shadow(color: .black, radius: 0, x: 1, y: 1)
                }.frame(maxWidth: .infinity)
            }
            .font(.custom("Splatfont2", size: 18))
        }
        .frame(height: 100)
    }
    
    
    var ResultWaveView: some View {
        HStack(alignment: .top) {
            ForEach(result.wave, id:\.self) { wave in
                VStack(spacing: 5) {
                    if result.wave.index(of: wave)! + 1 == (result.failure_wave.value) {
                        Text(result.failure_reason!.localized)
                            .padding(.bottom, 5)
                            .modifier(Splatfont2(size: 14))
                            .foregroundColor(.cOrange)
                            .frame(height: 12)
                    } else {
                        Text("")
                            .padding(.bottom, 5)
                            .frame(height: 12)
                    }
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text("WAVE")
                            Text(" \(wave.result.first!.wave.index(of: wave)! + 1)")
                        }
                        .foregroundColor(.black)
                        .font(.custom("Splatfont2", size: 16))
                        Text("\(wave.golden_ikura_num)/\(wave.quota_num)")
                            .font(.custom("Splatfont2", size: 26))
                            .padding(.horizontal, 5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .minimumScaleFactor(0.7)
//                            .lineLimit(1)
                            .background(Color.init(UIColor.init("2A270B")))
                        Group {
                            Text("\(wave.ikura_num)")
                                .foregroundColor(.red)
                            Text(wave.water_level!.localized)
                            Text(wave.event_type!.localized)
                        }
                        .frame(height: 26)
                        .foregroundColor(.black)
                        .font(.custom("Splatfont2", size: 16))
                    }
                    .background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 3.0))
                    HStack(spacing: 0) {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 15, height: 15)
                            .padding(.horizontal, 3)
                        Text("Appearances")
//                            .lineLimit(1)
                        Text(" x\(wave.golden_ikura_pop_num)")
                    }
                    .font(.custom("Splatfont2", size: 12))
                    ForEach(result.special_usage(wave.result.first!.wave.index(of: wave)!), id:\.self) { usage in
                        HStack(spacing: 0) {
                            ForEach(usage, id:\.self) { special in
                                URLImage(url: SpecialType(special_id: special)!.image_url) { image in image.resizable() }
                                    .frame(width: maxWidth/4, height: maxWidth/4)
                            }
                        }
                        .frame(width: maxWidth, alignment: .leading)
                    }
                }
            }
            .frame(width: maxWidth)
            .rotationEffect(.degrees(-2))
        }
    }
    
    var ResultPlayerView: some View {
        ForEach(result.player, id:\.self) { player in
            VStack(alignment: .leading, spacing: 0) {
                Text("\(isVisible ? player.name.value : "-")")
                    .font(.custom("Splatfont2", size: 18))
                    .frame(maxWidth:. infinity)
                    .padding(.leading, -maxWidth * 1.5)
                HStack {
                    WeaponListView(player: player)
                    PlayeResultView(player: player)
                }
                .frame(maxWidth: .infinity)
//                HStack(spacing: 0) {
//                    Text("Matching")
//                    Text(" x\(player.count)")
//                }
//                LegacyStyleView(player: player)
            }
            .frame(alignment: .bottom)
        }
        .font(.custom("Splatfont2", size: 16))
    }
    
    struct LegacyStyleView: View {
        var player: PlayerResultsRealm
        
        private let BOSS = [
            "https://app.splatoon2.nintendo.net/images/bundled/9b2673de42f00d4fd836bd4684741505.png",
            "https://app.splatoon2.nintendo.net/images/bundled/337dde2c83705a75263aefdc15740f1c.png",
            "https://app.splatoon2.nintendo.net/images/bundled/631ea65c8cc2d9fd04f6c7458914d030.png",
            "https://app.splatoon2.nintendo.net/images/bundled/79d75f769115befab060b27401538402.png",
            "https://app.splatoon2.nintendo.net/images/bundled/2466752cf11ef6326e2add430101bff6.png",
            "https://app.splatoon2.nintendo.net/images/bundled/862656b37d071e75ad31750c9e18ed15.png",
            "https://app.splatoon2.nintendo.net/images/bundled/367e6e1c33ab3ae2a1c857f4c75f017e.png",
            "https://app.splatoon2.nintendo.net/images/bundled/7f8e44737240e3caa52d6c4f457164d9.png",
            "https://app.splatoon2.nintendo.net/images/bundled/7ecdec1e23a3d0089b38038b0217827c.png"
        ]
        
        var body: some View {
            HStack {
                ForEach(player.result.first!.boss_counts.indices, id:\.self) { idx in
                    if (player.result.first!.boss_counts[idx] != 0) {
                        URLImage(url: URL(string: BOSS[idx])!) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 10) }
                        Text("\(player.boss_kill_counts[idx])")
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct WeaponListView: View {
        
        var player: PlayerResultsRealm
        var maxWidth: CGFloat = UIScreen.main.bounds.size.width >= 360 ? 35 : 30
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 3) {
                    ForEach(player.weapon_list, id:\.self) { weapon in
                        URLImage(url: WeaponType(weapon_id: weapon)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: maxWidth)}
                    }
                    URLImage(url: SpecialType(special_id: player.special_id)!.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: maxWidth)}
                }
                HStack(spacing: 0) {
                    if UIScreen.main.bounds.size.width >= 360 {
                        Text("Boss Salmonids defeated")
                    } else {
                        Text("Boss Defeated")
                    }
                    Text(" x\(player.boss_kill_counts.sum())")
                }
                .font(.custom("Splatfont2", size: 12))
                .shadow(color: .black, radius: 0, x: 1, y: 1)
                .foregroundColor(Color.init(UIColor.init("E5F100")))
            }
//            .frame(maxWidth: .infinity)
        }
    }
    
    struct PlayeResultView: View {
        
        var player: PlayerResultsRealm
        var maxWidth: CGFloat = UIScreen.main.bounds.size.width >= 360 ? 78.5 : 65
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Spacer()
                        Text("x" + String(player.golden_ikura_num))
//                            .lineLimit(1)
                    }
                    .frame(width: maxWidth)
                    .padding(.horizontal, 5)
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/efe826cfd1d44d19153f08e19f6caa2a.png")!) { image in image.resizable()}
                            .frame(width: 20.5, height: 15)
                        Spacer()
                        Text("x" + String(player.ikura_num))
//                            .lineLimit(1)
                    }
                    .frame(width: maxWidth)
                    .padding(.horizontal, 5)
                }
                HStack {
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!) { image in image.resizable()}
                            .frame(width: 33.4, height: 12.8)
                        Spacer()
                        Text("x" + String(player.help_count))
                    }
                    .frame(width: maxWidth)
                    .padding(.horizontal, 5)
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!) { image in image.resizable()}
                            .frame(width: 33.4, height: 12.8)
                        Spacer()
                        Text("x" + String(player.dead_count))
                    }
                    .frame(width: maxWidth)
                    .padding(.horizontal, 5)
                }
            }
//            .frame(maxWidth: .infinity)
        }
    }
    
    private struct ResultDetailView: View {
        
        @EnvironmentObject var result: CoopResultsRealm
        @Binding var isVisible: Bool
        @State var ILORATE: [Double?] = [nil, nil, nil, nil]
        @State var BIAS: [Double?] = [nil, nil, nil, nil]
        
        private let DEFAULT_IMAGE = "https://raw.githubusercontent.com/tkgstrator/Salmonia2/master/Salmonia2/Assets.xcassets/Default.imageset/default-1.png"
        
        private let BOSS = [
            "https://app.splatoon2.nintendo.net/images/bundled/9b2673de42f00d4fd836bd4684741505.png",
            "https://app.splatoon2.nintendo.net/images/bundled/337dde2c83705a75263aefdc15740f1c.png",
            "https://app.splatoon2.nintendo.net/images/bundled/631ea65c8cc2d9fd04f6c7458914d030.png",
            "https://app.splatoon2.nintendo.net/images/bundled/79d75f769115befab060b27401538402.png",
            "https://app.splatoon2.nintendo.net/images/bundled/2466752cf11ef6326e2add430101bff6.png",
            "https://app.splatoon2.nintendo.net/images/bundled/862656b37d071e75ad31750c9e18ed15.png",
            "https://app.splatoon2.nintendo.net/images/bundled/367e6e1c33ab3ae2a1c857f4c75f017e.png",
            "https://app.splatoon2.nintendo.net/images/bundled/7f8e44737240e3caa52d6c4f457164d9.png",
            "https://app.splatoon2.nintendo.net/images/bundled/7ecdec1e23a3d0089b38038b0217827c.png"
        ]

        
        var body: some View {
            List {
                Section(header: Header) {
                    BossView
                }
                Section(header: Text("Eval").font(.custom("Splatfont2", size: 16))) {
                    PlayerScoreView
                        .font(.custom("Splatfont2", size: 16))
                }
            }
        }
        
        var PlayerScoreView: some View {
            Group {
                HStack {
                    Text("Defeated")
                        .frame(width: 40)
                    ForEach(result.player, id:\.self) { player in
                        Text(String(player.boss_kill_counts.sum()))
                            .minimumScaleFactor(0.7)
//                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                    }
                }
                HStack {
                    Text("Score")
                        .frame(width: 40)
                    ForEach(result.player, id:\.self) { player in
                        Text(String(player.srpower))
                            .minimumScaleFactor(0.7)
//                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        
        var BossView: some View {
            ForEach(result.boss_counts.indices, id:\.self) { idx in
                if result.boss_counts[idx] != 0 {
                    HStack {
                        VStack(spacing: 0) {
                            URLImage(url: URL(string: BOSS[idx])!) { image in image.resizable().aspectRatio(1, contentMode: .fit) }
                                .frame(width: 35)
                            if result.boss_kill_counts[idx] == result.boss_counts[idx] {
                                Text("\(result.boss_kill_counts[idx])/\(result.boss_counts[idx])")
                                    .frame(height: 12)
                                    .font(.custom("Splatfont2", size: 14))
                                    .foregroundColor(.yellow)
                            } else {
                                Text("\(result.boss_kill_counts[idx])/\(result.boss_counts[idx])")
                                    .frame(height: 12)
                                    .font(.custom("Splatfont2", size: 14))
                            }
                        }
                        .frame(width: 40)
                        ForEach(result.player, id:\.self) { player in
                            VStack(spacing: 0) {
                                if player.boss_kill_counts[idx] == result.player.map({ $0.boss_kill_counts[idx] }).max() {
                                    Text("\(player.boss_kill_counts[idx])")
                                        .foregroundColor(.yellow)
                                } else {
                                    Text("\(player.boss_kill_counts[idx])")
                                }
                            }
                            .font(.custom("Splatfont2", size: 16))
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        
        var Header: some View {
            HStack {
                ForEach(result.player, id:\.self) { player in
                    VStack(spacing: 0) {
                        URLImage(url: URL(string: isVisible ? player.imageUri : DEFAULT_IMAGE)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                            .frame(width: 50, height: 50)
                        Text(isVisible ? player.name.value : "-")
//                            .lineLimit(1)
                    }
                    .font(.custom("Splatfont2", size: 12))
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.leading, 45)
        }
    }
    
}
            
//                ForEach(Range(0 ... 8), id:\.self) { id in
//                    if result.boss_counts[id] != 0 {
//                        HStack {
//                            VStack(spacing: 0) {
//                                URLImage(url: URL(string: BOSS[id])!) { image in image.resizable().aspectRatio(1, contentMode: .fit) }
//                                    .frame(width: 35)
//                                if result.boss_kill_counts[id] == result.boss_counts[id] {
//                                    Text("\(result.boss_kill_counts[id])/\(result.boss_counts[id])")
//                                        .frame(height: 12)
//                                        .font(.custom("Splatfont", size: 14))
//                                        .foregroundColor(.yellow)
//                                } else {
//                                    Text("\(result.boss_kill_counts[id])/\(result.boss_counts[id])")
//                                        .frame(height: 12)
//                                        .font(.custom("Splatfont", size: 14))
//                                }
//                            }
//                            .frame(width: 50)
//                            ForEach(result.player, id:\.self) { player in
//                                VStack(spacing: 0) {
//                                    Text("\(player.boss_kill_counts[id])")
//
//                                }
//                                .font(.custom("Splatfont", size: 16))
//                                .frame(maxWidth: .infinity)
//                            }
//                        }
//                    }
//                }
//                HStack {
//                    Text("Score")
//                        .frame(width: 50)
//                        .font(.custom("Splatfont", size: 14))
//                    ForEach(result.player, id:\.self) { player in
//                        Text(String(player.srpower))
//                            .minimumScaleFactor(0.7)
//                            .lineLimit(1)
//                            .font(.custom("Splatfont", size: 16))
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//                HStack {
//                    Text("Match")
//                        .frame(width: 50)
//                        .font(.custom("Splatfont", size: 14))
//                    ForEach(result.player, id:\.self) { player in
//                        Text(String(player.count))
//                            .font(.custom("Splatfont", size: 16))
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//            .background(Color.black)
//            .edgesIgnoringSafeArea(.all)
        
//        private var Geggs: some View {
//            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
//                .frame(width: 15, height: 15)
//        }
//        private var Peggs: some View {
//            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
//                .frame(width: 15, height: 15)
//        }

func CalcBias(_ result: CoopResultsRealm, _ nsaid: String) -> Double {
    let player: PlayerResultsRealm = result.player.filter("nsaid=%@", nsaid).first!
    let danger_rate: Double = result.danger_rate
    let rate: Double = (danger_rate * 3 / 5.0 + 80) / 160.0 // レートから計算されるバイアス
    let max_bias: Double = danger_rate == 200 ? 1.5 : 1.25 // 最大のバイアス

    var bias: (defeated: Double, golden: Double) = (0.0, 0.0)
    
    let quota_num = result.wave.map({ $0.quota_num }).reduce(0, +)
    let defeated_num = player.boss_kill_counts.sum()
    let appear_num = result.boss_counts.sum()
    
    let golden_ikura_num = player.golden_ikura_num
    
    bias.defeated = min(Double(defeated_num * 99) / Double(17 * appear_num), max_bias)
    bias.golden = min(rate + Double(10 * (golden_ikura_num * 3 - quota_num)) / (9.0 * 160.0), max_bias)
    
    switch (bias.golden < rate, bias.defeated < rate) {
    case (true, true):
        return max(bias.golden, bias.defeated)
    case (true, false):
        return max(bias.defeated, rate)
    case (false, true):
        return min(bias.defeated, rate)
    case (false, false):
        return min(bias.golden, bias.defeated)
    }
}

extension PlayerResultsRealm {
    var srpower: Double {
        let bossrate: [Int] = [1783, 1609, 2649, 1587, 1534, 1563, 1500, 1783, 2042]
        let bias: Double = CalcBias(self.result.first!, self.nsaid!)
        let baserate: Int = Array(zip(self.boss_kill_counts, bossrate)).map{ $0 * $1 }.reduce(0, +) / max(1, self.boss_kill_counts.sum())
        
        return Double(Double(baserate) * bias).round(digit: 1)
    }
}
