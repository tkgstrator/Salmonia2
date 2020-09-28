//
//  SettingView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import SplatNet2
import RealmSwift
import WebKit

struct SettingView: View {
    @EnvironmentObject var user: UserInfoCore
    @State var isVisible: Bool = false
    @State var code: String = ""
    @State var message: String = ""
    
    let oauthurl = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
    let version: String = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!))(\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)))"
    
    var body: some View {
        List {
            Section(header: Text("Accounts").font(.custom("Splatfont", size: 18))) {
                NavigationLink(destination: UserListView().environmentObject(UserInfoCore())) {
                    Text("List")
                }
            }
            Section(header: Text("Login").modifier(Splatfont(size: 18))) {
                Button(action: {
                    UIApplication.shared.open(URL(string: oauthurl)!)
                }) {
                    HStack {
                        Text("SplatNet2")
                        Spacer()
                        Image(systemName: "safari").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }
                Button(action: {
                    WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
                        cookies in
                        for cookie in cookies {
                            if cookie.name == "laravel_session" {
                                let laravel_session = cookie.value
                                do {
                                    let api_token = try SalmonStats.getAPIToken(laravel_session)
                                    guard let realm = try? Realm() else { throw APIError.Response("0001", "Realm DB Error")}
                                    let user = realm.objects(UserInfoRealm.self)
                                    try? realm.write { user.setValue(api_token, forKey: "api_token")}
                                    return
                                } catch APIError.Response(let error, let description) {
                                    isVisible = true
                                    code = error
                                    message = description
                                } catch {
                                    isVisible = true
                                    code = "9999"
                                    message = "Unknown Error"
                                }
                            }
                        }
                        isVisible = true
                        code = "9005"
                        message = "No laravel session"
                    }
                }) {
                    HStack {
                        Text("Salmon Stats").modifier(Splatfont(size: 20))
                        Spacer()
                        Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                    
                }
            }.alert(isPresented: $isVisible) {
                Alert(title: Text("Error \(code)"), message: Text(message))
            }
            Section(header: Text("Status").font(.custom("Splatfont", size: 18))) {
                HStack {
                    Text("iksm session")
                    Spacer()
                    Text("\((user.iksm_session != nil ? "Registered" : "Unregistered").localized)")
                }
                HStack {
                    Text("laravel session")
                    Spacer()
                    Text("\((user.api_token != nil ? "Registered" : "Unregistered").localized)")
                }
            }
            Section(header: Text("Application").font(.custom("Splatfont", size: 18))) {
                NavigationLink(destination: UnlockFeatureView()) {
                    HStack {
                        Text("Unlock")
                        Spacer()
                        Text("Feature")
                    }
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(version)")
                }
            }
        }
        .navigationBarTitle("Settings")
        .modifier(Splatfont(size: 20))
        .modifier(SettingsHeader())
    }
}
