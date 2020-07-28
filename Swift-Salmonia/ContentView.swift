//
//  ContentView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-20.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// タブを表示しているビュー
struct ContentView: View {
    var body: some View {
        TabView {
            SalmoniaView()
                .tabItem {
                    VStack {
                        Image(systemName: "a")
                        Text("Salmonia")
                    }
            }.tag("Salmonia")
            PlayerStatsView()
                .tabItem {
                    VStack {
                        Image(systemName: "snow")
                        Text("Stats")
                    }
            }.tag("Stats")
            SalmonStatsView()
                .tabItem {
                    VStack {
                        Image(systemName: "snow")
                        Text("Salmon Stats")
                    }
            }.tag("SalmonStats")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
