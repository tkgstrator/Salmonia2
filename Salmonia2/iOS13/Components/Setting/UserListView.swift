//
//  UserListView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage
import RealmSwift

struct UserListView: View {
    
    @EnvironmentObject var user: SalmoniaUserCore
    @State private var editMode = EditMode.inactive
    @State var isVisible: Bool = false

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
                        Toggle(isOn: $user.isActiveArray[idx]) { }
                            .disabled(!user.isPurchase)
                            .onTapGesture{ onActive(idx: idx) }
                    }
                }
                .onMove(perform: onMove)
            }
//            .onDelete(perform: onDelete)
        }
        .sheet(isPresented: $isVisible) {
            SFSafariView(url: URL(string: oauthurl)!)
        }
        .navigationBarTitle("Accounts")
        .modifier(Splatfont(size: 18))
        .navigationBarItems(trailing: Login)
        .environment(\.editMode, $editMode)
    }
    
    private var Login: some View {
        HStack {
            Button(action: {
                if !user.isUnlock[3] {
                    isVisible.toggle()
                } else {
                    UIApplication.shared.open(URL(string: oauthurl)!)
                }
            }) { Text("Add") }
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
