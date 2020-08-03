//
//  SalmonStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// SalmonStatsを表示するためのビュー（ただし強制再リロードがかかってしまってダサい）
struct SalmonStatsView: View {
    let main = UIApplication.shared.delegate as! AppDelegate
    
    var body: some View {
        WebView(request: URLRequest(url: URL(string: "https://salmon-stats-api.yuki.games/auth/twitter")!))
            .navigationBarTitle("SalmonStats", displayMode: .inline)
    }
}

//struct SalmonStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonStatsView()
//    }
//}
