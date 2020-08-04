//
//  WebView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-04.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import WebKit

// SalmonStatsを表示するためのビュー（ただし強制再リロードがかかってしまってダサい）
struct LoginView: View {
    var body: some View {
        WebView(request: URLRequest(url: URL(string: "https://salmon-stats-api.yuki.games/auth/twitter")!))
            .navigationBarTitle("SalmonStats", displayMode: .inline)
    }
}

struct WebView: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}
