//
//  SettingsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON

// 設定画面を表示するビュー
struct SettingsView: View {
    private let url = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
    
    @State private var isVisible: Bool = false
    @State private var title: String = ""
    @State private var text: String = ""
    
    private var iksm_session: String?
    private var session_token: String?
    private var api_token: String?
    
    init(user: UserInformation) {
        iksm_session = user.iksm_session
        session_token = user.session_token
        api_token = user.api_token
    }
    
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
                    SplatNet2.loginSalmonStats() { response in
                        // エラー処理をする（何事もなければ単にリターンして終わり
                        guard let error = response else { return }
                        switch error {
                        case let APPError.Response(id, message):
                            self.title = "Error Code \(id)"
                            self.text = message
                            self.isVisible = true
                        default:
                            break
                        }
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
            Section(header: Text("UserInfo")) {
                SettingColumn(title: "iksm_session", value: iksm_session)
                SettingColumn(title: "session_token", value: session_token)
                SettingColumn(title: "api_token", value: api_token)
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
        .navigationBarItems(trailing:
            NavigationLink(destination: SalmonStatsView()) {
                Image(systemName: "snow").resizable().scaledToFit().frame(width: 30, height: 30)
            }
        )
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

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
