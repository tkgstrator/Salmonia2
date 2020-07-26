//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-24.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Text("Loading View")
            .onAppear() {
                // 表示されたときの任意の関数実行
                SplatNet2.getSummaryFromSplatNet2() { response in
                    print(response)
                }
                
        }
    }
}

