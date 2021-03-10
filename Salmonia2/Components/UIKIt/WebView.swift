//
//  WebView.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-08.
//

import SwiftUI
import WebKit
import Combine

public class SUIWebBrowserObject: WKWebView, WKNavigationDelegate, ObservableObject {
    private var observers: [NSKeyValueObservation?] = []
    
    private func subscriber<Value>(for keyPath: KeyPath<SUIWebBrowserObject, Value>) -> NSKeyValueObservation {
        observe(keyPath, options: [.prior]) { object, change in
            if change.isPrior {
                self.objectWillChange.send()
            }
        }
    }
    
    private func setupObservers() {
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }
    
    public override init(frame: CGRect = .zero, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
        setupObservers()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationDelegate = self
        setupObservers()
    }
}

public struct SUIWebBrowserView: UIViewRepresentable {
    public typealias UIViewType = UIView
    
    private var browserObject: SUIWebBrowserObject
    
    public init(browserObject: SUIWebBrowserObject) {
        self.browserObject = browserObject
    }
    
    public func makeUIView(context: Self.Context) -> Self.UIViewType {
        browserObject
    }
    
    public func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
        //
    }
}

struct WebBrowser: View {
    @EnvironmentObject var main: MainCore
    @ObservedObject var browser = SUIWebBrowserObject()
    @Environment(\.presentationMode) var presentationMode
    
    init(address: String) {
        guard let a = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let u = URL(string: a) else { return }
        browser.load(URLRequest(url: u))
    }
    
//    func ItemImage(systemName: String) -> some View {
//        Image(systemName: systemName)
//            .imageScale(.large).aspectRatio(contentMode: .fit)
//            .frame(width: 32, height: 32)
//    }
    
    var Title: Text {
        Text(verbatim: browser.url?.absoluteString.removingPercentEncoding ?? "")
    }
    
    var body: some View {
        SUIWebBrowserView(browserObject: browser)
            .onAppear {
                WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
                    cookies in
                    for cookie in cookies {
                        if cookie.name == "laravel_session" {
                            let laravel_session = cookie.value
                            DispatchQueue(label: "Login").async {
                                Thread.sleep(forTimeInterval: 10)
                                do {
                                    main.apiToken = try SalmonStats.getAPIToken(laravel_session)
                                    main.isLogin.toggle()
                                    print("LOGIN DONE")
                                } catch {
                                    
                                }
                            }
                        }
                    }
                }
            }
    }
}
