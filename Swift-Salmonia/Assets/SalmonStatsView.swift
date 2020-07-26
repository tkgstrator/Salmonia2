//
//  SalmonStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-24.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import WebKit

struct SalmonStatsView: UIViewRepresentable {
    var loadUrl:String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: URL(string: loadUrl)!))
    }
}
