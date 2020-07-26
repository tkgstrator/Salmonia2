//
//  ContentView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-20.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage
import Combine

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

class UserInfoModel: ObservableObject {
    public var users: Results<UserInfoRealm> = UserInfoRealm.all()
    public var objectWillChange: ObservableObjectPublisher = .init()
    private var notificationTokens: [NotificationToken] = []
    
    // 最初にDBから読み込むのだが、一度しか呼ばれないので発火しない
    init() {
        notificationTokens.append(users.observe { _ in
            self.objectWillChange.send()
            })
    }
}

// Salmoniaのビュー（まだなんにも書いてない）
struct SalmoniaView: View {
    @ObservedObject var realm = UserInfoModel()
    let url = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    HStack(alignment: .center, spacing: 0) {
                        URLImage(URL(string: realm.users.first?.image ?? url)!, processors: [Resize(size: CGSize(width: 40, height: 40), scale: UIScreen.main.scale)])
                        Spacer()
                        Text(realm.users.first?.name ?? "Salmonia").font(.custom("Splatfont2", size: 30)).frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    //Text("UNDER CONSTRUCTION")
                }
            }
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingsView())
                {
                    Image(systemName: "gear").resizable().scaledToFit().frame(width: 30, height: 30)
                }, trailing:
                NavigationLink(destination: LoadingView())
                {
                    Image(systemName: "arrow.clockwise.icloud").resizable().scaledToFit().frame(width: 30, height: 30)
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


// SalmonStatsを表示するためのビュー（ただし強制再リロードがかかってしまってダサい）
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

// 設定画面を表示するビュー
struct SettingsView: View {
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
            Button(action: {
                //                self.isVisible.toggle()
            }) {
                Text("Salmon Stats")
            }
        }
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


