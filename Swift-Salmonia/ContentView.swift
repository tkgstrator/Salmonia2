//
//  ContentView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-20.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
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
            }.tag(0)
            SalmonStatsView()
                .tabItem {
                    VStack {
                        Image(systemName: "a")
                        Text("Salmonia")
                    }
            }.tag(1)
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
                self.isVisible = !self.isVisible
            }) {
                Text("SplatNet2")
            }
            .sheet(isPresented: $isVisible) {
                WebView()
            }
        }
        .navigationBarTitle(Text("Settings"))
    }
}

struct WebView: View {
    var body: some View {
        SafariView(url: URL(string: "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form")!)
    }
}

struct SafariView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) { }
}

#if DEBUG
struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
        SafariView(url: URL(string: "https://accounts.nintendo.com/connect/1.0.0/authorize?state=cPiy40Mxm2mQSDgsRogPN1Vl-MQsESPAU0Y-42Nsv_Rh9NVB&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=VMVN1fpASeN1QtzJP_v8Buwd_2ea1TMsywLVEo1ZUsU&session_token_code_challenge_method=S256&theme=login_form")!)
    }
}
#endif

