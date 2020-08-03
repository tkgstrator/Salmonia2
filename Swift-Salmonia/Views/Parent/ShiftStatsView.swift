//
//  ShiftStatsVIew.swift
//  
//
//  Created by devonly on 2020-08-03.
//

import SwiftUI

struct ShiftStatsView: View {
    var body: some View {
        List {
            ForEach(Range(1...20)) { _ in
                Text("Shift Stats")
            }
        }.navigationBarTitle("Stats")
    }
}

struct ShiftStatsView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftStatsView()
    }
}
