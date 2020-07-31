//
//  SalmoniaView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine
import URLImage

class UserInfoModel: ObservableObject {
    public var users: Results<UserInfoRealm> = UserInfoRealm.all()
    public var objectWillChange: ObservableObjectPublisher = .init()
    private var notificationTokens: [NotificationToken] = []
    
    // 最初にDBから読み込むのだが、一度しか呼ばれないので発火しない
    init() {
        notificationTokens.append(users.observe { _ in
            self.objectWillChange.send()
        })
    }
}

struct UserView: View {
    @ObservedObject var realm = UserInfoModel()
    let url = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    
    var body: some View {
        HStack(spacing: 0) {
            URLImage(URL(string: realm.users.first?.image ?? url)!, content:  {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}).frame(width: 80, height: 80)
            Spacer()
            Text(realm.users.first?.name ?? "Salmonia").font(.custom("Splatfont2", size: 30)).frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}

// Salmoniaのビュー（まだなんにも書いてない）
struct SalmoniaView: View {

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UserView()
                    OverView()
                }
            }
            .padding(.horizontal, 10)
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingsView())
                {
                    Image(systemName: "gear").resizable().scaledToFit().frame(width: 30, height: 30)
                }, trailing:
                NavigationLink(destination: LoadingView())
                {
                    Image(systemName: "arrow.clockwise.icloud").resizable().scaledToFit().frame(width: 30, height: 30)
                }
            )
        }
    }
}


struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
