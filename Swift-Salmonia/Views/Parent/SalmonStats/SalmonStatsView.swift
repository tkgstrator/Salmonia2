//
//  SalmonStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import URLImage

// Salmon Stats利用者のビュー（Salmon StatsのWebViewではない）
// Salmon Statsをブラウザレスで簡易的に閲覧するためのView
struct SalmonStatsView: View {
    @Binding var nsaid: String
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            SalmonStatsPlayerView(nsaid: $nsaid)
            SalmonStatsOverview(nsaid: $nsaid)
            SalmonStatsShiftView(nsaid: $nsaid)
        }
        .padding(.horizontal, 10)
        .navigationBarTitle("\(nsaid)")
    }
}

private struct SalmonStatsPlayerView: View {
    @Binding var nsaid: String
    @State var nickname: String?
    @State var imageUri: String?
    
    var body: some View {
        HStack {
            NavigationLink(destination: SalmonStatsResultsView(nsaid: $nsaid)) {
                URLImage(URL(string: imageUri.value)!,
                         content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                    .frame(width: 80, height: 80)
            }.buttonStyle(PlainButtonStyle())
            Text(nickname.value).font(.custom("Splatfont", size: 28)).frame(maxWidth: .infinity)
        }.onAppear(){
            SplatNet2.getPlayerNickname(nsaid: self.nsaid){ response in
                self.nickname = response["nickname_and_icons"][0]["nickname"].stringValue
                self.imageUri = response["nickname_and_icons"][0]["thumbnail_url"].stringValue
            }
        }
    }
}

private struct SalmonStatsOverview: View {
    @Binding var nsaid: String
    @State var job_count: Int?
    @State var ikura_total: Int?
    @State var ikura_average: Int?
    @State var golden_ikura_average: Int?
    @State var golden_ikura_total: Int?
    @State var defeated: Double?
    
    var body: some View {
        VStack {
            Text("Overview")
                .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatfont", size: 20))
            HStack {
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(job_count.value)")
                }
                Spacer()
                VStack {
                    Text("Eggs")
                    HStack {
                        Text("\(golden_ikura_total.value)").foregroundColor(.yellow)
                        Text("/")
                        Text("\(ikura_total.value)").foregroundColor(.red)
                    }
                }
                Spacer()
                VStack {
                    Text("Defeated")
                    Text("\(self.defeated.value)")
                }
            }.font(.custom("Splatfont", size: 18))
        }.onAppear() {
            SalmonStats.getPlayerOverView(nsaid: self.nsaid) { response in
                self.job_count = response[0]["results"]["clear"].intValue + response[0]["results"]["fail"].intValue
                self.ikura_total = response[0]["total"]["power_eggs"].intValue
                self.ikura_average = self.ikura_total! / self.job_count!
                self.golden_ikura_total = response[0]["total"]["golden_eggs"].intValue
                self.golden_ikura_average = self.golden_ikura_total! / self.job_count!
                self.defeated = Double(response[0]["total"]["boss_elimination_count"].doubleValue / Double(self.job_count!)).round(digit: 2)
                //                    self.information.overview = PlayerOverview(job_count: job_count, ikura_total: ikura_total, golden_ikura_total: golden_ikura_total, kuma_point_total: nil)
            }
        }
    }
}

private struct SalmonStatsShiftView: View {
    @Binding var nsaid: String
    @State var shiftstats: [JSON] = []
    @State var start_time: [Int] = []
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Shift Stats")
                //            .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatfont", size: 20))
            ForEach(start_time.indices, id:\.self) { idx in
                NavigationLink(destination: SalmonStatShiftStatsView(nsaid: self.$nsaid, start_time: self.$start_time[idx])) {
                    ShiftStack(phase: self.$shiftstats[idx])
                }.buttonStyle(PlainButtonStyle())
            }
        }.onAppear() {
            SalmonStats.getPlayerShiftStats(nsaid: self.nsaid) { response in
                self.shiftstats = response.arrayValue
                self.start_time = self.shiftstats.map({ SSTime(time: $0["schedule_id"].stringValue) }).prefix(5).map({ $0 })
            }
        }
    }
}

private struct SalmonStatShiftStatsView: View {
    @Binding var nsaid: String
    @Binding var start_time: Int
    @State var stats: SalmonStatsFormat = SalmonStatsFormat()
    private let boss: [String] = ["Goldie", "Steelhead", "Flyfish", "Scrapper", "Steel Eel", "Stinger", "Maws", "Griller", "Drizzler"]
    
    init(nsaid: Binding<String>, start_time: Binding<Int>) {
        _nsaid = nsaid
        _start_time = start_time
    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("Overview").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                HStack {
                    Text("Games")
                    Spacer()
                    Text("\(stats.games)")
                }
                HStack {
                    Text("Clear")
                    Spacer()
                    Text(String(stats.clear_ratio))
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Boss Samonids").font(.custom("Splatfont", size: 18))
                Spacer()
            }) {
                ForEach(stats.my_defeated.indices, id:\.self) { idx in
                    HStack {
                        Text(self.boss[idx])
                        Spacer()
                        ProgressView(value: [self.stats.my_defeated[idx], self.stats.other_defeated[idx]])
                    }
                }
            }
        }
        .font(.custom("Splatfont", size: 16))
        .navigationBarTitle("Player Stats")
        .onAppear() {
            SalmonStats.getPlayerShiftStatsDetail(nsaid: self.nsaid, start_time: self.start_time) { response in
                self.stats = SalmonStats.encodeStats(response)
            }
        }
    }
}

private struct ShiftStatsStack: View {
    @Binding var stack: JSON
    
    var body: some View {
        HStack {
            Text("")
            Spacer()
            Text("")
        }
    }
}


private struct ShiftStack: View {
    @Binding var phase: JSON
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 27, height: 18)})
                Text(Unixtime(interval: Unixtime(time: phase["schedule_id"].stringValue))).frame(height: 18)
                Text(verbatim: "-").frame(height: 18)
                Text(Unixtime(interval: Unixtime(time: phase["end_at"].stringValue))).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(URL(string: ImageURL.stage(phase["stage_id"].intValue + 4999))!, content: {$0.image.resizable().frame(width: 112, height: 63)
                }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
                HStack {
                    ForEach((phase["weapons"].intObject), id:\.self) { weapon in
                        URLImage(URL(string: ImageURL.weapon(weapon))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    }
                }.frame(maxWidth: .infinity)
            }.frame(height: 63)
        }.frame(height: 100)
            .font(.custom("Splatfont2", size: 18))
    }
}

//struct SalmonStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonStatsView()
//    }
//}
