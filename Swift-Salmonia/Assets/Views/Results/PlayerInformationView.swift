//
//  PlayerInformationView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-31.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct PlayerInformationView: View {

    @State var information = UserInformation()
    
    // コンストラクタで情報をとってこればロード中にならないのだが、complitionで問題が発生する
    // DispatchQueue()をコピペで使ったらロードが終わるまでmainスレッドが固まってしまった
    // コンストラクタ内でDispatchQueue.global().asyncすればいけるかも？
    
    init() {
        // 本当は宣言時にロードしたい
        
    }
    
    var body: some View {
        ScrollView {
            UserInformationView(user: information).disabled(true)
            PlayerOverView(data: information)
        }
        .padding(.horizontal, 10)
        .onAppear() {
            SplatNet2.getPlayerInformationFromSplatNet2(nsaid: "fdacccf138ebca81") { response in
                self.information.username = response["nickname_and_icons"][0]["nickname"].stringValue
                self.information.imageUri = response["nickname_and_icons"][0]["thumbnail_url"].stringValue
            }
            SplatNet2.getPlayerInformationFromSalmonStats(nsaid: "fdacccf138ebca81") { response in
                let job_count = response[0]["results"]["clear"].intValue + response[0]["results"]["fail"].intValue
                let ikura_total = response[0]["total"]["power_eggs"].intValue
                let golden_ikura_total = response[0]["total"]["golden_eggs"].intValue
                self.information.overview = PlayerOverview(job_count: job_count, ikura_total: ikura_total, golden_ikura_total: golden_ikura_total, kuma_point_total: nil)
            }
        }.navigationBarTitle("PlayerInfo")
    }
}

//struct PlayerInformationView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerInformationView()
//    }
//}
