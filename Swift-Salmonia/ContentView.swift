//
//  ContentView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-20.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import WebKit
import SafariServices

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
            SalmonStatsView()
                .tabItem {
                    VStack {
                        Image(systemName: "a")
                        Text("Salmonia")
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

// タブの定義（後で別ファイルにわける予定）
struct SalmoniaView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Text("未実装")
            }
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingView())
                {
                    Text("Settings")
                }
            )
        }
    }
}
struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}

struct SalmonStatsView: View {
    var body: some View {
        Text("SalmonStats View")
    }
}
struct SalmonStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SalmonStatsView()
    }
}


struct SettingView: View {
    @State var isVisible = false

    var body: some View {
        List {
            Button(action: {
                self.isVisible.toggle()
            }) {
                Text("SplatNet2")
            }
            .sheet(isPresented: $isVisible) {
                WebView()
            }
        }
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
    }
}
