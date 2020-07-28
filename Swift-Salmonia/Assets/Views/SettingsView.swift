//
//  SettingsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

// 設定画面を表示するビュー
struct SettingsView: View {
    private let url = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
    
    @ObservedObject var realm = UserInfoModel()

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
                    SplatNet2.loginSalmonStats()
                }) {
                    HStack {
                        Text("Salmon Stats")
                        Spacer()
                        Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }
            }
            Section(header: Text("UserInfo")) {
                SettingColumn(title: "iksm_session", value: realm.users.first?.iksm_session)
                SettingColumn(title: "session_token", value: realm.users.first?.session_token)
                SettingColumn(title: "api_token", value: realm.users.first?.api_token)
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
    }
}

struct SettingColumn: View {
    var title: String
    var value: String

    init(title: String, value: String?) {
        self.title = title
        self.value = value != nil ? "Registered" : "Unregistered"
    }
    
    var body: some View {
        HStack {
            Text(self.title)
            Spacer()
            Text(self.value).foregroundColor(Color.gray)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
