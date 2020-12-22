//
//  WebView.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-08.
//

import SwiftUI
import WebKit

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
    @ObservedObject var browser = SUIWebBrowserObject()
    @Environment(\.presentationMode) var presentationMode
    
    init(address: String) {
        guard let a = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let u = URL(string: a) else { return }
        browser.load(URLRequest(url: u))
    }
    
    func ItemImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .imageScale(.large).aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    var Title: Text {
        Text(verbatim: browser.url?.absoluteString.removingPercentEncoding ?? "")
    }
    
    var LItems: some View {
        HStack {
            Button(action: {
                self.browser.goBack()
            }) {
                ItemImage(systemName: "chevron.left")
            }.disabled(!browser.canGoBack)
        }
    }
    
    var TItems: some View {
        Login
//        HStack {
//            Button(action: {
//                if self.browser.isLoading {
//                    self.browser.stopLoading()
//                } else {
//                    self.browser.reload()
//                }
//            }) {
//                ItemImage(systemName: browser.isLoading
//                            ? "xmark"
//                            : "arrow.clockwise"
//                )
//            }
//        }
    }
    
    func notification(title: Notification, message: Notification) {
        
        let content = UNMutableNotificationContent()
        content.title = title.localizedDescription.localized
        content.body = message.localizedDescription.localized
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func notification(title: Notification, error: Error) {
        
        let content = UNMutableNotificationContent()
        content.title = title.localizedDescription.localized
        content.body = error.localizedDescription.localized
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    private var Login: some View {
        Button(action: {
            WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
                cookies in
                for cookie in cookies {
                    if cookie.name == "laravel_session" {
                        let laravel_session = cookie.value
                        do {
                            let api_token = try SalmonStats.getAPIToken(laravel_session)
                            let user = realm.objects(SalmoniaUserRealm.self)
                            try? realm.write { user.setValue(api_token, forKey: "api_token")}
                            notification(title: .success, message: .laravel)
                            return
                        } catch {
                            notification(title: .failure, error: error)
                        }
                    }
                }
                //                notification(title: .failure, message: .laravel)
            }
        }) {
            Image(systemName: "snow")
                .Modifier()
                .foregroundColor(.blue)
        }
    }
    
    var body: some View {
        
        //       NavigationView {
        SUIWebBrowserView(browserObject: browser)
            .edgesIgnoringSafeArea(.all)
        //               .navigationBarTitle("Salmon Stats")
            .navigationBarItems(leading: LItems, trailing: TItems)
        //       }.navigationViewStyle(StackNavigationViewStyle())
    }
}
