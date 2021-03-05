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
            Section(header: Text("My Accounts")
                .modifier(Splatfont2(size: 16))
                .foregroundColor(.cOrange))
            {
                ForEach(user.account.indices, id:\.self) { idx in
                    HStack {
                        URLImage(url: URL(string: user.account[idx].image)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                            .frame(width: 60, height: 60)
                        Text(user.account[idx].name).frame(maxWidth: .infinity)
//                        Toggle(isOn: $user.isActiveArray[idx]) { }
//                            .disabled(!user.isPurchase)
//                            .onTapGesture{ onActive(idx: idx) }
                    }
                }
                .onMove(perform: onMove)
            }
//            .onDelete(perform: onDelete)
        }
        .navigationBarTitle("Accounts")
        .modifier(Splatfont(size: 18))
        .navigationBarItems(trailing: Login)
        .environment(\.editMode, $editMode)
    }
    
    var Login: some View {
        HStack {
            Button(action: { isVisible = true }) { Text("Add") }
                .webAuthenticationSession(isPresented: $isVisible) {
                    WebAuthenticationSession(
                        url: URL(string: oauthurl)!,
                        callbackURLScheme: "npf71b963c1b7b6d119")
                    { callbackURL, error in
                        guard let session_token_code = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                        print(session_token_code)
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
                            try realm.write {
                                let value: [String: Any?] = ["nsaid": nsaid, "name": nickname, "image": thumbnail_url, "iksm_session": iksm_session, "session_token": session_token, "isActive": true]
                                realm.create(UserInfoRealm.self, value: value, update: .all)
                            }
                            print("LOGIN DONE")
                        } catch {
                            // TODO: エラー発生時の処理を書く
                        }
                    }
                }
                .alert(isPresented: $isSuccess) {
                    Alert(title: !isFailure ? Text("Success") : Text("Failure"), message: !isFailure ? Text("Login/Update SplatNet2") : Text(errorMessage.value))
                }
            EditButton()
        }
//            .font(.system(size: 18))
    }
    
    private func onActive(idx: Int) {
        let isActive: Bool = user.account[idx].isActive
        let nsaid: String = user.account[idx].nsaid
        let value: [String: Any] = ["isActive": !isActive, "nsaid": nsaid]
        user.account[idx].update(value)
    }
    
    private func onDelete(offsets: IndexSet) {
        try? Realm().write {
            user.account.remove(atOffsets: offsets)
        }
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        try? Realm().write {
            user.account.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    private let oauthurl = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
