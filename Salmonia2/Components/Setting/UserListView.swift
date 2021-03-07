//
//  UserListView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import SafariServices
import URLImage
import RealmSwift
import BetterSafariView
import Alamofire
import SwiftyJSON
import SplatNet2

struct UserListView: View {
    @EnvironmentObject var user: UserInfoCore
    @State private var editMode = EditMode.inactive
    @State var isVisible: Bool = false
    @State var isSuccess: Bool = false
    @State var isFailure: Bool = false
    @State var isUserInteraction: Bool = false
    @State var errorMessage: String? = nil
    
    var body: some View {
        List {
            Section(header: Text("HEADER_ACTIVE")
                        .modifier(Splatfont2(size: 16))
                        .foregroundColor(.cOrange))
            {
                ForEach(user.active, id:\.self) { account in
                    HStack(spacing: 0) {
                        URLImage(url: URL(string: account.image)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                            .frame(width: 60, height: 60)
                        Text(account.name)
                            .modifier(Splatfont2(size: 18))
                            .frame(maxWidth: .infinity)
                    }
//                    .contextMenu(ContextMenu(menuItems: {
//                        Button(action: { onFlipState(source: account) } ) { Text("SETTING_DISABLE") }
//                        Button(action: { } ) { Text("SETTING_UPDATE") }
//                    }))
                }
                .onMove(perform: onMove)
                .onDelete { offset in
                    onFlipState(source: user.active[offset.map{$0}[0]])
                }
            }
            Section(header: Text("HEADER_INACTIVE")
                        .modifier(Splatfont2(size: 16))
                        .foregroundColor(.cOrange))
            {
                ForEach(user.inactive, id:\.self) { account in
                    HStack(spacing: 0) {
                        URLImage(url: URL(string: account.image)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                            .frame(width: 60, height: 60)
                        Text(account.name)
                            .modifier(Splatfont2(size: 18))
                            .frame(maxWidth: .infinity)
                    }
//                    .contextMenu(ContextMenu(menuItems: {
//                        Button(action: { onFlipState(source: account) } ) { Text("SETTING_DISABLE") }
//                        Button(action: { } ) { Text("SETTING_UPDATE") }
//                    }))
                }
                .onMove(perform: onMove)
                .onDelete { offset in
                    onFlipState(source: user.inactive[offset.map{$0}[0]])
                }
            }
        }
        .navigationTitle("HEADER_MY_ACCOUNTS")
        .modifier(Splatfont(size: 18))
        .navigationBarItems(trailing: Login)
        .environment(\.editMode, $editMode)
    }
    
    struct UserList: View {
        @State var account: UserInfoRealm
        var body: some View {
            HStack {
                Text(account.name).frame(maxWidth: .infinity)
            }
        }
    }
    
    var Login: some View {
        HStack {
            Button(action: { isVisible = true }) { Text("BTN_ADD") }
                .webAuthenticationSession(isPresented: $isVisible) {
                    WebAuthenticationSession(
                        url: URL(string: oauthurl)!,
                        callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, error in
                        DispatchQueue(label: "Login").async {
                            guard let session_token_code = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                            let session_token_code_verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak"
                            let version: String = "1.10.1"
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
                                
                                // 書き込むべきデータ
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
                            } catch {
                                // TODO: エラー発生時の処理を書く
                            }
                        }
                    }
                }
                .alert(isPresented: $isSuccess) {
                    Alert(title: !isFailure ? Text("Success") : Text("Failure"), message: !isFailure ? Text("Login/Update SplatNet2") : Text(errorMessage.value))
                }
            EditButton()
        }
        .buttonStyle(DefaultButtonStyle())
    }

    private func onFlipState(source: UserInfoRealm) {
        // TODO: 切り替えはできているけど、変化がダサい
        realm.beginWrite()
        source.isActive.toggle()
        try? realm.commitWrite()
    }
    

    private func onMove(source: IndexSet, destination: Int) {
        user.active.move(fromOffsets: source, toOffset: destination)
    }
    
    private let oauthurl = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
