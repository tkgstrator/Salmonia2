//
//  Modifier.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import URLImage
import RealmSwift
import WebKit

struct Splatfont: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Splatfont", size: size))
        //            .frame(height: size)
    }
}

struct SalmoniaHeader: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .navigationBarItems(leading:
                                    NavigationLink(destination: SettingView().environmentObject(SalmoniaUserCore()))
                                    {
                                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/bb035c04e62c044139986540e6c3b8b3.png")!,
                                                 content: {$0.image.renderingMode(.template).resizable()})
                                            .frame(width: 30, height: 30).foregroundColor(.white)
                                    },
                                trailing:
                                    NavigationLink(destination: LoadingView())
                                    {
                                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                                                 content: {$0.image.renderingMode(.original).resizable()})
                                            .frame(width: 30, height: 30)
                                    }
            )
    }
}

struct SettingsHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarItems(trailing:
                                    NavigationLink(destination: WebKitView())
                                    {
                                        Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                                    })
    }
}

private struct WebKitView: View {
    var body: some View {
        WebView(request: URLRequest(url: URL(string: "https://salmon-stats-api.yuki.games/auth/twitter")!))
            .navigationBarTitle("SalmonStats")
            .navigationBarItems(trailing: login)
    }
    
    // 通知を出す
    func notification(title: Title, message: Message) {
        
        let content = UNMutableNotificationContent()
        content.title = title.rawValue.localized
        content.body = message.rawValue.localized
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private var login: some View {
        Button(action: {
            WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
                cookies in
                for cookie in cookies {
                    if cookie.name == "laravel_session" {
                        let laravel_session = cookie.value
                        do {
                            let api_token = try SalmonStats.getAPIToken(laravel_session)
                            guard let realm = try? Realm() else { throw APIError.Response("0001", "Realm DB Error")}
                            let user = realm.objects(SalmoniaUserRealm.self)
                            try? realm.write { user.setValue(api_token, forKey: "api_token")}
                            notification(title: .success, message: .laravel)
                            return
                        } catch  {
                        }
                    }
                }
                notification(title: .failure, message: .laravel)
            }
        }) {
            Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
        }
    }
}

private struct WebView: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}
