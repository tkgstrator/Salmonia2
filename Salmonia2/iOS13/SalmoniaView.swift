//
//  SalmoniaView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI

struct SalmoniaView: View {
    var body: some View {
        ScrollView {
            PlayerView()
            CoopShiftView()
            StageRecordView()
        }
        .padding(.horizontal, 10)
        .modifier(SalmoniaHeader())
        .environmentObject(UserInfoCore())
        .environmentObject(CoopShiftCore())
        .navigationBarTitle("Salmonia")
    }
}

struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
