//
//  ShiftRotationView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct FutureShiftView: View {
    
    var body: some View {
        ForEach(Range(1...3)) { _ in
            NavigationLink(destination: ShiftStatsView()) {
                ShiftStack()

            }
        }
    }
}

// 他のビューから参照したくないのでprivateにする
private struct ShiftStack: View {
    var body: some View {
        Text("ShiftStackView")
    }
}
struct FutureShiftView_Previews: PreviewProvider {
    static var previews: some View {
        FutureShiftView()
    }
}
