//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-26.
//

import SwiftUI
import RealmSwift
import URLImage

struct CoopShiftView: View {
    @EnvironmentObject var phase: CoopShiftCore
    
    var body: some View {
        ForEach(phase.data.indices, id:\.self) { idx in
            ZStack {
                NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phase.data[idx].start_time))) { EmptyView() }
                .opacity(0.0)
                CoopShiftStack(phase: phase.data[idx])
            }
        }
        NavigationLink(destination: CoopShiftCollectionView()) { Text("TITLE_SHIFT_SCHEDULE").font(.custom("Splatfont2", size: 16)) }
    }
}


struct CoopShiftView_Previews: PreviewProvider {
    static var previews: some View {
        CoopShiftView()
    }
}
