//
//  SalmoniaView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

// 自分を表示するためのビュー
struct SalmoniaView: View {
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            PlayerView() // プレイヤーの概要を表示
            FutureShiftView() // 将来のシフトを表示
            StageListView() // 記録を表示
            OptionView()
        }
            // なんかここダサいけど直し方わからん
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingView())
                {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/bb035c04e62c044139986540e6c3b8b3.png")!,
                             content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).foregroundColor(.white)})
                        .frame(width: 30, height: 30)
                }, trailing:
                NavigationLink(destination: LoadingView())
                {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                             content: {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 30, height: 30)
                }
        )
            .padding(.horizontal, 10)
    }
}

//struct SalmoniaView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmoniaView()
//    }
//}
