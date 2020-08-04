//
//  ResultView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct ResultView: View {
    @State var waves: RealmSwift.List<WaveDetailRealm>
    @State var players: RealmSwift.List<PlayerResultsRealm>
    
    init(data: CoopResultsRealm) {
        _waves = State(initialValue: data.wave)
        _players = State(initialValue: data.player)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    ForEach(Range(1...waves.count)) { idx in
                        ResultWaveView(wave: self.$waves[idx - 1])
                    }
                }
                VStack {
                    ForEach(Range(1...players.count)) { idx in
                        ResultPlayerView(player: self.$players[idx - 1])
                    }
                }
            }
        }
        .navigationBarTitle("Detail")
    }
}


// リザルト表示につかう子コンポーネント
private struct ResultWaveView: View {
    @Binding var wave: WaveDetailRealm
    
    var body: some View {
        VStack {
            VStack {
                Text("WAVE").foregroundColor(.black)
                HStack {
                    Text(String(wave.golden_ikura_num)).padding(0)
                    Text("/").padding(0)
                    Text(String(wave.quota_num)).padding(0)
                }.foregroundColor(.white)
                    .frame(height: 36).frame(minWidth: 120)
                    .background(Color.black)
                    .font(.custom("Splatfont2", size: 28))
                Text(String(wave.ikura_num)).foregroundColor(.red).frame(height: 28).font(.custom("Splatfont2", size: 22))
                Text(wave.water_level).foregroundColor(.black).frame(height: 28)
                Text(wave.event_type).foregroundColor(.black).frame(height: 28)
            }.background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 8.0))
            Text(String(wave.golden_ikura_pop_num)).foregroundColor(.white).frame(height: 28)
        }
    }
}

//private struct ResultWaveView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultWaveView()
//    }
//}

private struct ResultPlayerView: View {
    @Binding var player: PlayerResultsRealm
    
    var body: some View {
        NavigationLink(destination: SalmonStatsView(nsaid: $player.nsaid)) {
            VStack(spacing: 0) {
                HStack {
                    Text(player.name)
                }
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
                }
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

//private struct ResultPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultPlayerView()
//    }
//}


//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
