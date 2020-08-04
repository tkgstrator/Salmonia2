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
    //    @Binding var geometry: CGFloat
    
    var body: some View {
        HStack {
            NavigationLink(destination: ResultsCollectionView()) {
                URLImage(URL(string: self.user.imageUri!)!,
                         content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                    .frame(width: 80, height: 80)
            }.buttonStyle(PlainButtonStyle())
            Text(self.user.nickname.value).font(.custom("Splatfont2", size: 26)).frame(maxWidth: .infinity)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
