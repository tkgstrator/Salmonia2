//
//  SalmonStatsView.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-03.
//

import SwiftUI

struct SalmonStatsView: View {
    var nsaid: String
    
    var body: some View {
        ScrollView {
            OtherPlayerView()
                .environmentObject(CrewInfoCore(nsaid))
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(nsaid)
    }
}

//struct SalmonStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonStatsView()
//    }
//}
