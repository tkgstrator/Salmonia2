//
//  SettingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        List {
            ForEach(Range(1...10)) { _ in
                Text("Setting View")
            }
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
