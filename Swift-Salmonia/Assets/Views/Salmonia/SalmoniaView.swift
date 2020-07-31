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
    private var token: NotificationToken?
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
//    @Published var information: UserInformation = UserInformation(name:nil, url: nil, iksm_session: nil, session_token: nil, api_token: nil)
    @Published var information: UserInformation = UserInformation()

    init() {
        token = realm?.observe{ _ in
            self.information = UserInformation(name: nil, url: nil, iksm_session: nil, session_token: nil, api_token: nil)
            // 変更があったときに実行されるハンドラ
            guard let user = try? Realm().objects(UserInfoRealm.self).first else { return }
            let iksm_session = user.iksm_session
            let session_token = user.session_token
            let api_token = user.api_token
//
            self.information = UserInformation(name: user.name, url: user.image, iksm_session: iksm_session, session_token: session_token, api_token: api_token)
        }
    }
}

struct UserInformationView: View {

    private var name: String
    private var image: String
    
    init(user: UserInformation){
        name = user.username ?? "Salmonia"
        image = user.imageUri ?? "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: ResultsCollectionView()) {
                URLImage(URL(string: image)!, content:  {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}).frame(width: 80, height: 80)
            }
            Spacer()
            Text(name).font(.custom("Splatfont2", size: 30)).frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}

// Salmoniaのビュー（まだなんにも書いてない）
struct SalmoniaView: View {
    @ObservedObject var users = UserInfoModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UserInformationView(user: users.information)
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
