//
//  ProgressView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-13.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    private var maxValue: Double = 0.0
    private var dataValue: [Double] = []
    
    init(value: [Double]) {
        maxValue = value.max() ?? 1.0
        dataValue = value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(dataValue.indices, id:\.self) { idx in
                HStack {
                    Rectangle().frame(width: CGFloat(120 / self.maxValue * self.dataValue[idx]), height: 10).foregroundColor(self.textColor(idx, self.maxValue == self.dataValue[idx])).cornerRadius(40.0)
                    Text(String(self.dataValue[idx])).font(.custom("Splatfont2", size: 16)).frame(width: 80, height: 20)
                }
            }
        }.frame(width: 200)
    }
    
    func textColor(_ idx: Int, _ valid: Bool) -> Color {
        return idx == 0 ? valid ? .blue : .red : .white
    }
}

//struct ProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressView()
//    }
//}
