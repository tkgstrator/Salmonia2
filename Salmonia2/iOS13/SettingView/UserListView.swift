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
    
    @State var isVisible: Bool = false
    @State var log: (code: String, message: String) = ("", "")
    
    var body: some View {
        List {
            ForEach(user.account.indices, id: \.self) { idx in
                HStack {
                    URLImage(URL(string: user.account[idx].image)!,
                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 60, height: 60)
                    Text(user.account[idx].name).frame(maxWidth: .infinity)
                    Toggle(isOn: $user.isActiveArray[idx]) {
                        //                        Text("Display Rare Weapon")
                    }
                    .disabled(!user.isPurchase)
                    .onTapGesture{
                        do {
                            let isActive: Bool = user.account[idx].isActive
                            let nsaid: String = user.account[idx].nsaid
                            let value: [String: Any] = ["isActive": !isActive, "nsaid": nsaid]
                            user.account[idx].update(value)
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
            .onMove(perform: { (source, destination) in
                do {
                    try? Realm().write {
                        user.account.move(fromOffsets: source, toOffset: destination)
                    }
                } catch {
                    
                }
            })
        }
        .navigationBarItems(trailing: EditButton())
        .navigationBarTitle("User List")
        .modifier(Splatfont(size: 20))
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}
