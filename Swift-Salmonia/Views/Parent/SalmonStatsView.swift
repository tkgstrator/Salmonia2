//
//  SalmonStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// Salmon Stats利用者のビュー（Salmon StatsのWebViewではない）
struct SalmonStatsView: View {
    @Binding var nsaid: String
    
    var body: some View {
        ScrollView {
            PlayerView()
        }
        .navigationBarTitle("\(nsaid)")
    }
}

//struct SalmonStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonStatsView()
//    }
//}
