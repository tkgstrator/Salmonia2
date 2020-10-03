//
//  SalmonStatsView.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-03.
//

import SwiftUI

struct SalmonStatsView: View {
    @EnvironmentObject var player: CrewInfoCore
    
    var body: some View {
        ScrollView {
            OtherPlayerView()
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(player.nickname)
    }
}

struct SalmonStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SalmonStatsView()
    }
}
