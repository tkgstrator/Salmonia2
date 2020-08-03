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



struct UserInformationView: View {
    private var name: String
    private var image: String
    
    init(user: UserInformation){
        name = user.username ?? "-"
        image = user.imageUri ?? "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: ResultsCollectionView()) {
                URLImage(URL(string: image)!, content:  {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}).frame(width: 22.vw, height: 22.vw)
            }
            Spacer()
            Text(name).font(.custom("Splatfont2", size: 8.vw)).frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}

struct SalmoniaView: View {
    @ObservedObject var users = UserInfoModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UserInformationView(user: users.information)
                    PlayerOverView(data: users.information)
                }
            }
            .padding(.horizontal, 10)
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingsView(user: users.information))
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
