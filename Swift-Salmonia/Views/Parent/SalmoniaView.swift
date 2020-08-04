//
//  SalmoniaView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// 自分を表示するためのビュー
struct SalmoniaView: View {
    var body: some View {
        ScrollView {
            PlayerView() // プレイヤーの概要を表示
            FutureShiftView() // 将来のシフトを表示
            StageListView() // 記録を表示
        }
            // なんかここダサいけど直し方わからん
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingView())
                {
                    Image(systemName: "gear").resizable().scaledToFit().frame(width: 30, height: 30)
                }, trailing:
                NavigationLink(destination: LoadingView())
                {
                    Image(systemName: "arrow.clockwise.icloud").resizable().scaledToFit().frame(width: 30, height: 30)
                }
        )
    .padding(.horizontal, 10)
    }
}

struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
