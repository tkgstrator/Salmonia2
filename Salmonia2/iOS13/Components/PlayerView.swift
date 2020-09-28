//
//  PlayerView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct PlayerView: View {
    @EnvironmentObject var user: UserInfoCore
    @EnvironmentObject var card: UserCardCore

    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) {
                    URLImage(URL(string: user.imageUri)!,
                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 80, height: 80)
                }.buttonStyle(PlainButtonStyle())
                Text(user.nickname).modifier(Splatfont(size: 28)).frame(maxWidth: .infinity)
            }
            Text("Overview").foregroundColor(.orange).modifier(Splatfont(size: 20))
            HStack {
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(card.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                    HStack {
                        Text("\(card.golden_ikura_total)").foregroundColor(.yellow)
                        Text("/")
                        Text("\(card.ikura_total)").foregroundColor(.red)
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Points")
                    Text("\(card.kuma_point_total)")
                }
            }.modifier(Splatfont(size: 18))
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
