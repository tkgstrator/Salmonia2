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
    @EnvironmentObject var phases: CoopShiftCore
    
    var body: some View {
        ForEach(phases.data.indices, id:\.self) { idx in
            ZStack {
                NavigationLink(destination: ShiftStatsView(stats: UserStatsCore(start_time: phases.data[idx].start_time))) {
                    EmptyView()
                }
                .opacity(0.0)
                CoopShiftStack(phase: phases.data[idx])
            }
        }
        NavigationLink(destination: CoopShiftCollectionView()) {
            Text("Coop Shift Rotation")
                .modifier(Splatfont2(size: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct CoopShiftView_Previews: PreviewProvider {
    static var previews: some View {
        CoopShiftView()
    }
}
