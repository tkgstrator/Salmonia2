//
//  ResultDetailView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-31.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct WaveView: View {
    private var wave: WaveDetailRealm
    private var number: Int
    
    init(data: WaveDetailRealm, num: Int) {
        wave = data
        number = num
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("WAVE " + String(number + 1)).foregroundColor(.black)
                HStack {
                    Text(String(wave.golden_ikura_num)).padding(0)
                    Text("/").padding(0)
                    Text(String(wave.quota_num)).padding(0)
                }
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

struct PlayerView: View {
    private var player: PlayerResultsRealm
    private var defeated: Int?
    
    init(data: PlayerResultsRealm) {
        player = data
        defeated = player.defeat.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(player.name)
                Text(defeated.string)
            }
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                    .frame(width: 20, height: 20)
                Text(String(player.golden_ikura_num)).frame(width: 30)
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                    .frame(width: 20, height: 20)
                Text(String(player.ikura_num)).frame(width: 45)
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!, content: {$0.image.resizable()})
                    .frame(width: 50, height: 20)
                Text(String(player.help_count)).frame(width: 30)
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!, content: {$0.image.resizable()})
                    .frame(width: 50, height: 20)
                Text(String(player.dead_count)).frame(width: 30)
            }
        }
    }
}

struct ResultDetailView: View {
    
    private var result: CoopResultsRealm = CoopResultsRealm()
    
    init(job_id: Int?) {
        guard let id = job_id else { return }
        guard let data = try? Realm().objects(CoopResultsRealm.self).filter("job_id=%@", id).first else { return }
        self.result = data
    }
    
    var body: some View {
        ScrollView {
            HStack {
                ForEach(result.wave.indices, id: \.self) { num in
                    WaveView(data: self.result.wave[num], num: num)
                }
            }
            VStack {
                ForEach(result.player, id: \.self) { player in
                    NavigationLink(destination: PlayerInformationView(nsaid: player.nsaid)) {
                        PlayerView(data: player)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 10)
        .navigationBarTitle("Result")
        .font(.custom("Splatfont2", size: 18))
    }
}

//struct ResultDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultDetailView()
//    }
//}
