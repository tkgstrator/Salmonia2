//
//  LoginMenu.swift
//  Salmonia2
//
//  Created by Devonly on 2021/03/05.
//

import SwiftUI
import BetterSafariView
import SplatNet2
import SwiftyJSON
import RealmSwift

struct LoginMenu: View {
    @State var isPresented: Bool = false
    @State var isActive: Bool = false
    @State var isAlert: Bool = false
    @State var isEnable: [Bool] = [false, false]
    @State var appError: CustomNSError?
    
    // TODO: とりあえず今は定数を使っている
    private var version: String = UserDefaults.standard.string(forKey: "version") ?? "1.11.0"
    private var oauthURL: URL = URL(string: "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form")!
    private var loginURL: URL = URL(string: "https://my.nintendo.com/login")!
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 30) {
                    Text("TEXT_WELCOME")
                        .font(.custom("RobotoMono", size: 60))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                    Text("DESC_LOGIN_SPLATNET2")
                        .font(.custom("RobotoMono", size: 30))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .position(x: geometry.frame(in: .local).midX, y: geometry.size.height / 4)
                VStack(spacing: 40) {
                    LoginButton
                    RegisterButton
                }
                .position(x: geometry.frame(in: .local).midX, y: 3 * geometry.size.height / 5)
            }
        }
        .background(BackGround)
        .navigationTitle("TITLE_WELCOME")
        .navigationBarHidden(true)
    }
    
    var LoginButton: some View {
        Button(action: { isEnable[0].toggle() }) {
            Text("BTN_LOGIN")
                .font(.custom("RobotoMono", size: 20))
                .foregroundColor(.white)
                .frame(width: 144, height: 42)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .webAuthenticationSession(isPresented: $isEnable[0]) {
            WebAuthenticationSession(url: oauthURL, callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, _ in
                DispatchQueue(label: "Login").async {
                    do {
                        guard let session_token_code = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { throw APPError.value }
                        let session_token_code_verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak"
                        var response: JSON = JSON()
                        response = try SplatNet2.getSessionToken(session_token_code, session_token_code_verifier)
                        guard let session_token: String = response["session_token"].string else { throw APPError.value }
                        response = try SplatNet2.genIksmSession(session_token, version: version)
                        guard let thumbnail_url = response["user"]["thumbnail_url"].string else { throw APPError.iksm }
                        guard let nickname = response["user"]["nickname"].string else { throw APPError.iksm }
                        guard let iksm_session = response["iksm_session"].string else { throw APPError.iksm }
                        guard let nsaid = response["nsaid"].string else { throw APPError.iksm }
                        guard let realm = try? Realm() else { throw APPError.realm }
                        
                        let value: [String: Any?] = ["nsaid": nsaid, "name": nickname, "image": thumbnail_url, "iksm_session": iksm_session, "session_token": session_token, "isActive": true]

                        // MainRealmの情報を更新する
                        realm.beginWrite()
                        switch realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid).isEmpty {
                        case true:
                            let user: UserInfoRealm = UserInfoRealm(value: value)
                            let uuid: String = UIDevice.current.identifierForVendor!.uuidString
                            guard let main: MainRealm = realm.objects(MainRealm.self).first else { return }
                            main.active.append(user)
                        case false:
                            realm.create(UserInfoRealm.self, value: value, update: .all)
                        }
                        try? realm.commitWrite()
                        // 終わったのでフラグを反転させる
                        isActive.toggle()
                    } catch (let error) {
                        // TODO: エラー発生時の処理を書く
                        appError = error as? CustomNSError
                        isPresented.toggle()
                    }
                }
            }
        }
        .alert(isPresented: $isPresented, error: appError)
    }
    
    var RegisterButton: some View {
        Button(action: { isEnable[1].toggle() }) {
            Text("BTN_REGISTER")
                .font(.custom("RobotoMono", size: 20))
                .foregroundColor(.white)
                .frame(width: 144, height: 42)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)
        }
        .safariView(isPresented: $isEnable[1]) {
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
        }
    }
}

struct LoginMenu_Previews: PreviewProvider {
    static var previews: some View {
        LoginMenu()
    }
}
