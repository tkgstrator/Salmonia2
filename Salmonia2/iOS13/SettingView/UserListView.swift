//
//  UserListView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct UserListView: View {
    @EnvironmentObject var users: UserInfoCore
    @EnvironmentObject var user: SalmoniaUserCore

    @State var isVisible: Bool = false
    @State var log: (code: String, message: String) = ("", "")
    
    var body: some View {
        List {
            ForEach(users.account.indices, id: \.self) { idx in
                HStack {
                    URLImage(URL(string: users.account[idx].image)!,
                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 60, height: 60)
                    Text(users.account[idx].name).frame(maxWidth: .infinity)
                    Toggle(isOn: $users.isActiveArray[idx]) {
//                        Text("Display Rare Weapon")
                    }
                    .disabled(!user.isPurchase)
                    .onTapGesture{
                        do {
                            let isActive: Bool = users.account[idx].isActive
                            let nsaid: String = users.account[idx].nsaid
                            let value: [String: Any] = ["isActive": !isActive, "nsaid": nsaid]
                            try users.account[idx].update(value)
                        } catch APIError.Response(let code, let message){
                            isVisible = true
                        } catch {
                            print("UNKNOWN ERROR")
                        }
                    }
                    .alert(isPresented: $isVisible) {
                        Alert(title: Text("Error \(log.code)"), message: Text(log.message))
                    }
                }
            }
        }
        .navigationBarTitle("User List")
        .modifier(Splatfont(size: 20))
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
