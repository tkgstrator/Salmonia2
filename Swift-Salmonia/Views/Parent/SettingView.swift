//
//  SettingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    private let url = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
    
    @ObservedObject var user = UserInfoCore()
    // エラーを表示するためのやつ
    @State private var isVisible: Bool = false
    @State private var title: String = ""
    @State private var text: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Login")) {
                Button(action: {
                    UIApplication.shared.open(URL(string: self.url)!)
                }) {
                    HStack {
                        Text("SplatNet2")
                        Spacer()
                        Image(systemName: "safari").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }
                Button(action: {
                    SalmonStats.loginSalmonStats() { response in
                    }
                }) {
                    HStack {
                        Text("Salmon Stats")
                        Spacer()
                        Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }.alert(isPresented: $isVisible) {
                    Alert(title: Text(title),message: Text(text))
                }
            }
            Section(header: Text("Unlock")) {
                Toggle(isOn: $user.is_unlock) {
                    Text("Display Rare Weapon")
                }.onTapGesture{
                    self.user.updateUnlock(!self.user.is_unlock)
                }
            }
            Section(header: Text("Feature")) {
                NavigationLink(destination: ImportedView()) {
                    HStack {
                        Text("Import from SalmonStats")
                        Spacer()
                    }
                }
                NavigationLink(destination: SyncUserNameView()) {
                    HStack {
                        Text("Sync Username from SplatNet2")
                        Spacer()
                    }
                }
                NavigationLink(destination: CompleteShiftView()) {
                    HStack {
                        Text("Future Rotation")
                        Spacer()
                    }
                }
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
        .navigationBarItems(trailing:
            // ここの機能クソすぎだから別の仕組み考えたいんだけどね
            NavigationLink(destination: LoginView()) {
                Image(systemName: "snow").resizable().scaledToFit().frame(width: 30, height: 30)
            }
        )
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
