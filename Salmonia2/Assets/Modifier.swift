//
//  Modifier.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import URLImage
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
                                    NavigationLink(destination: SettingView()
                                                    .environmentObject(UserInfoCore())
                                                    .environmentObject(SalmoniaUserCore())
                                    )
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
