//
//  WebView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-21.
//  Copyright © 2020 devonly. All rights reserved.
//
import SwiftUI
import SafariServices
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

//#if DEBUG
//struct WebView_Previews : PreviewProvider {
//    static var previews: some View {
//        WebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
//    }
//}
//#endif

struct SafariView: UIViewControllerRepresentable {

    typealias UIViewControllerType = SFSafariViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: URL(string: "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form")!)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
