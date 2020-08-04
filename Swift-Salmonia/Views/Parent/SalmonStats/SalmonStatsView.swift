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
struct SalmonStatsView: View {
    @Binding var nsaid: String
    @State var nickname: String?
    @State var imageUri: String?
    @State var job_count: Int?
    @State var ikura_total: Int?
    @State var ikura_average: Int?
    @State var golden_ikura_average: Int?
    @State var golden_ikura_total: Int?
    @State var defeated: Double?
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    NavigationLink(destination: SalmonStatsResultsView(nsaid: $nsaid)) {
                        URLImage(URL(string: imageUri.value)!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                            .frame(width: 80, height: 80)
                    }.buttonStyle(PlainButtonStyle())
                    Text(nickname.value).font(.custom("Splatfont2", size: 26)).frame(maxWidth: .infinity)
                }
                HStack {
                    VStack {
                        Text("Jobs")
                        Text("\(job_count.value)")
                    }
                    Spacer()
                    VStack {
                        Text("Eggs")
                        Text("\(ikura_total.value)/\(golden_ikura_total.value)")
                    }
                    Spacer()
                    VStack {
                        Text("Defeated")
                        Text("\(self.defeated.value)")
                    }
                }.font(.custom("Splatfont2", size: 18))
            }
        }
        .padding(.horizontal, 10)
        .onAppear() {
            SplatNet2.getPlayerNickname(nsaid: self.nsaid){ response in
                self.nickname = response["nickname_and_icons"][0]["nickname"].stringValue
                self.imageUri = response["nickname_and_icons"][0]["thumbnail_url"].stringValue
            }
            
            SalmonStats.getPlayerOverView(nsaid: self.nsaid) { response in
                self.job_count = response[0]["results"]["clear"].intValue + response[0]["results"]["fail"].intValue
                self.ikura_total = response[0]["total"]["power_eggs"].intValue
                self.ikura_average = self.ikura_total! / self.job_count!
                self.golden_ikura_total = response[0]["total"]["golden_eggs"].intValue
                self.golden_ikura_average = self.golden_ikura_total! / self.job_count!
                self.defeated = Double(response[0]["total"]["boss_elimination_count"].doubleValue / Double(self.job_count!)).round(digit: 2)
                //                    self.information.overview = PlayerOverview(job_count: job_count, ikura_total: ikura_total, golden_ikura_total: golden_ikura_total, kuma_point_total: nil)
            }
        }.navigationBarTitle("\(nsaid)")
    }
}

//struct SalmonStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonStatsView()
//    }
//}
