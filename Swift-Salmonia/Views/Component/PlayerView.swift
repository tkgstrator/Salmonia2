//
//  PlayerView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import URLImage

// プレイヤー名、画像などを表示する
struct PlayerView: View {
    @ObservedObject var user = UserInfoCore()
    @ObservedObject var card = UserCardCore()

    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: ResultsCollectionView()) {
                    URLImage(URL(string: self.user.imageUri.value)!,
                             content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 80, height: 80)
                }.buttonStyle(PlainButtonStyle())
                Text(self.user.nickname.value).font(.custom("Splatfont2", size: 26)).frame(maxWidth: .infinity).frame(height: 80)
            }.frame(height: 70)
            HStack {
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(card.job_num.value)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                    HStack {
                        Text("\(card.ikura_total.value)").foregroundColor(.red)
                        Text("/")
                        Text("\(card.golden_ikura_total.value)").foregroundColor(.yellow)
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Points")
                    Text("\(card.kuma_point_total.value)")
                }
            }
            .frame(height: 80)
            .font(.custom("Splatfont2", size: 18))
        }
    }
}

//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView()
//    }
//}
