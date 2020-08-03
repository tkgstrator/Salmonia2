//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
            Text("Loading View is under construction")
            ScrollView {
                Text("Log View")
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
