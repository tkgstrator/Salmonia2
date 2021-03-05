//
//  SalmonStatsMenu.swift
//  Salmonia2
//
//  Created by Devonly on 2021/03/05.
//

import SwiftUI
import BetterSafariView

struct SalmonStatsMenu: View {
    @State var isActive: Bool = false
    @State var isAlert: Bool = false
    @State var isEnable: [Bool] = [false, false, false]
    @State var error: APPError = .unknown
    
    private var oauthURL: URL = URL(string: "https://salmon-stats-api.yuki.games/auth/twitter?redirect_to=salmon-stats://")!
    private var loginURL: URL = URL(string: "https://twitter.com/i/flow/signup")!

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                BackGround
                VStack(spacing: 5) {
                    Text("TEXT_LOGIN_SALMON_STATS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                    Text("DESC_LOGIN_SALMON_STATS")
                        .font(.system(size: 16, weight: .thin, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .offset(x: 0, y: -geometry.size.height * 0.7)
                VStack(spacing: 40) {
                    ModernLoginButton
                    LegacyLoginButton
                    RegisterButton
                }
                .offset(x: 0, y: -80)
            }
        }
        .navigationTitle("TITLE_WELCOME")
        .navigationBarBackButtonHidden(true)
    }
    
    var ModernLoginButton: some View {
        Button(action: { isEnable[0].toggle() }) {
            Text("BTN_LOGIN_MODERN")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 240, height: 60)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .webAuthenticationSession(isPresented: $isEnable[0]) {
            WebAuthenticationSession(url: oauthURL, callbackURLScheme: "salmon-stats") { callbackURL, error in
                print(callbackURL, error)
            }
        }
    }
    
    var LegacyLoginButton: some View {
        Group {
            Button(action: { isEnable[1].toggle() }) {
                Text("BTN_LOGIN")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 240, height: 60)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    var RegisterButton: some View {
        Button(action: { isEnable[2].toggle() }) {
            Text("BTN_REGISTER_TWITTER")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 240, height: 60)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .safariView(isPresented: $isEnable[2]) {
            SafariView(url: loginURL,
                       configuration: SafariView.Configuration(
                        entersReaderIfAvailable: true,
                        barCollapsingEnabled: true
                       )
            )
            .preferredBarAccentColor(.clear)
            .preferredControlAccentColor(.accentColor)
            .dismissButtonStyle(.done)
        }
    }
    
    var BackGround: some View {
        Group {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            NavigationLink(destination: SalmonStatsMenu(), isActive: $isActive) { EmptyView() }
            NavigationLink(destination: WebBrowser(address: "https://salmon-stats-api.yuki.games/auth/twitter"), isActive: $isEnable[1]) { EmptyView() }
        }
    }
}

struct SalmonStatsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SalmonStatsMenu()
    }
}
