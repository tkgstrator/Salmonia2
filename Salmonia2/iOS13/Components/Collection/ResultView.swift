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
                        }
                    }
                }
                Group {
                    if self.result.danger_rate == 200 {
                        Text("Hazard Level MAX!!")
                            .modifier(Splatfont(size: 20))
                            .foregroundColor(.yellow)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Hazard Level " + String(self.result.danger_rate) + "%")
                            .modifier(Splatfont(size: 20))
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
            .font(.custom("Splatfont2", size: 18))
        }
        .frame(height: 100)
    }
    
    
    var ResultWaveView: some View {
        HStack(alignment: .top) {
            ForEach(result.wave, id:\.self) { wave in
                VStack(spacing: 5) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("WAVE \(wave.result.first!.wave.index(of: wave)! + 1)")
                        }
                        .foregroundColor(.black)
                        .font(.custom("Splatfont2", size: 16))
                        Text("\(wave.golden_ikura_num)/\(wave.quota_num)")
                            .font(.custom("Splatfont2", size: 26))
                            .padding(.horizontal, 5)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
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
        }
    }
    
    var ResultPlayerView: some View {
        ForEach(result.player, id:\.self) { player in
            NavigationLink(destination: SalmonStatsView(nsaid: player.nsaid!)) {
                VStack(spacing: 0) {
                    HStack {
                        Text(isVisible ? player.name.value : "-")
                        Spacer()
                        URLImage(url: SpecialType(special_id: player.special_id)!.image_url) { image in image.resizable() }
                            .frame(width: 30, height: 30)
                        ForEach(Range(0 ... result.wave.count - 1).indices, id:\.self) { wave in
                            URLImage(url: WeaponType(weapon_id: player.weapon_list[wave])!.image_url) { image in image.resizable() }
                                .frame(width: 30, height: 30)
                        }
                    }
                    .padding(.horizontal, 5)
                    HStack {
                        Spacer()
                        Group {
                            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                                .frame(width: 20, height: 20)
                            Text(String(player.golden_ikura_num)).frame(width: 30)
                        }
                        Spacer()
                        Group {
                            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                                .frame(width: 20, height: 20)
                            Text(String(player.ikura_num)).frame(width: 48)
                        }
                        Spacer()
                        if maxWidth == 100 {
                            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!) { image in image.resizable()}
                                .frame(width: 50, height: 20)
                            Text("\(player.help_count)/\(player.dead_count)").frame(width: 50)
                        } else {
                            Group {
                                URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!) { image in image.resizable()}
                                    .frame(width: 50, height: 20)
                                Text(String(player.help_count)).frame(width: 30)
                            }
                            Spacer()
                            Group {
                                URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!) { image in image.resizable()}
                                    .frame(width: 50, height: 20)
                                Text(String(player.dead_count)).frame(width: 30)
                            }
                        }
                        Spacer()
                    }
                    .frame(height: 24)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .font(.custom("Splatfont2", size: 16))
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
                HStack {
                    Text("").frame(width: 50)
                    ForEach(result.player, id:\.self) { player in
                        VStack(spacing: 0) {
                            if isVisible == true {
                                URLImage(url: URL(string: player.imageUri)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                                    .frame(width: 50, height: 50)
                                Text(player.name.value)
                                    .lineLimit(1)
                            } else {
                                URLImage(url: URL(string:  DEFAULT_IMAGE)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                                    .frame(width: 50, height: 50)
                                Text(verbatim: "-")
                            }
                            HStack {
                                Geggs
                                Text("\(player.golden_ikura_num)")
                            }
                            .frame(height: 16)
                            HStack {
                                Peggs
                                Text("\(player.ikura_num)")
                            }
                            .frame(height: 16)
                        }
                        .font(.custom("Splatfont", size: 12))
                        .frame(maxWidth: .infinity)
                    }
                }
                ForEach(Range(0 ... 8), id:\.self) { id in
                    if result.boss_counts[id] != 0 {
                        HStack {
                            VStack(spacing: 0) {
                                URLImage(url: URL(string: BOSS[id])!) { image in image.resizable().aspectRatio(1, contentMode: .fit) }
                                    .frame(width: 35)
                                if result.boss_kill_counts[id] == result.boss_counts[id] {
                                    Text("\(result.boss_kill_counts[id])/\(result.boss_counts[id])")
                                        .frame(height: 12)
                                        .font(.custom("Splatfont", size: 14))
                                        .foregroundColor(.yellow)
                                } else {
                                    Text("\(result.boss_kill_counts[id])/\(result.boss_counts[id])")
                                        .frame(height: 12)
                                        .font(.custom("Splatfont", size: 14))
                                }
                            }
                            .frame(width: 50)
                            ForEach(result.player, id:\.self) { player in
                                VStack(spacing: 0) {
                                    Text("\(player.boss_kill_counts[id])")
                                    
                                }
                                .font(.custom("Splatfont", size: 16))
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                HStack {
                    Text("Score")
                        .frame(width: 50)
                        .font(.custom("Splatfont", size: 14))
                    ForEach(result.player, id:\.self) { player in
                        Text(String(player.srpower))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                            .font(.custom("Splatfont", size: 16))
                    }
                    .frame(maxWidth: .infinity)
                }
                HStack {
                    Text("Match")
                        .frame(width: 50)
                        .font(.custom("Splatfont", size: 14))
                    ForEach(result.player, id:\.self) { player in
                        Text(String(player.count))
                            .font(.custom("Splatfont", size: 16))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }

        private var Geggs: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                .frame(width: 15, height: 15)
        }
        private var Peggs: some View {
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                .frame(width: 15, height: 15)
        }
    }
}

func CalcBias(_ result: CoopResultsRealm, _ nsaid: String) -> Double {
    let player: PlayerResultsRealm = result.player.filter("nsaid=%@", nsaid).first!
    let danger_rate: Double = result.danger_rate
    let rate: Double = (danger_rate * 3 / 5.0 + 80) / 160.0
    let max_bias: Double = danger_rate == 200 ? 1.5 : 1.25

    var bias: (defeated: Double, golden: Double) = (0.0, 0.0)
    
    let quota_num = result.wave.map({ $0.quota_num }).reduce(0, +)
    let defeated_num = player.boss_kill_counts.sum()
    let appear_num = result.boss_counts.sum()
    
    let golden_ikura_num = player.golden_ikura_num
    
    bias.defeated = min(Double(defeated_num * 99) / Double(17 * appear_num), max_bias)
    bias.golden = min(rate + Double(10 * (golden_ikura_num * 3 - quota_num)) / (9.0 * 160.0), max_bias)

    bias.defeated = bias.golden == max_bias ? max_bias : bias.defeated
    bias.golden = bias.defeated == max_bias ? max_bias : bias.golden

    return min(bias.defeated, bias.golden) >= rate ? max(bias.defeated, bias.golden) : max(bias.defeated, bias.golden) >= rate ? rate : min(bias.defeated, bias.golden)
}

extension PlayerResultsRealm {
    var srpower: Double {
        let bossrate: [Int] = [1783, 1609, 2649, 1587, 1534, 1563, 1500, 1783, 2042]
        let bias: Double = CalcBias(self.result.first!, self.nsaid!)
        let baserate: Int = Array(zip(self.boss_kill_counts, bossrate)).map{ $0 * $1 }.reduce(0, +) / max(1, self.boss_kill_counts.sum())
        
        return Double(Double(baserate) * bias).round(digit: 1)
    }
}
