//
//  PlayerView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// プレイヤー名、画像などを表示する
struct PlayerView: View {
    var body: some View {
        NavigationLink(destination: ResultsCollectionView()) {
            Text("Player View")
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
