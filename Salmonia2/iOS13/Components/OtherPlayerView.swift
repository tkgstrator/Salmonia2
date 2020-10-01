//
//  OtherPlayerView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import RealmSwift
import URLImage
import Combine

struct OtherPlayerView: View {
    @EnvironmentObject var player: CrewInfoCore
    
    var body: some View {
        ScrollView {
            HStack {
                //                                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) { //                    URLImage(URL(string: player.imageUri)!,
                //                                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                //                                        .frame(width: 80, height: 80)
                //                                }.buttonStyle(PlainButtonStyle())
                Text(player.nickname).modifier(Splatfont(size: 28)).frame(maxWidth: .infinity)
            }
            Text("Overview").foregroundColor(.orange).modifier(Splatfont(size: 20))
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Jobs")
//                    Text("\(player.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                    HStack {
//                        Text("\(player.golden_ikura_total)").foregroundColor(.yellow)
                        Text("/")
//                        Text("\(player.ikura_total)").foregroundColor(.red)
                    }
                }
                Spacer()
            }.modifier(Splatfont(size: 18))
        }
        //        .onAppear() { isFav = player.isFav }
        .navigationBarTitle(player.nsaid)
        .navigationBarItems(trailing: favButton)
    }
    
    private var favButton: some View {
        switch player.isFav {
        case true:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "star.fill") })
        case false:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "star.fill").foregroundColor(.gray) })
        }
    }
    
    private func onToggleFav() {
        guard let realm = try? Realm() else { return }
        guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
        guard let player = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", player.nsaid).first else { return }
        // あるなら追加、無いなら
        let _favuser = user.favuser.filter("nsaid=%@", player.nsaid)
        
        try! realm.write {
            switch _favuser.isEmpty {
            case true:
                user.favuser.append(player)
            case false:
                guard let index = user.favuser.index(of: player) else { return }
                user.favuser.remove(at: index)
            break
            }
        }
    }
}

//struct OtherPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherPlayerView(player: <#Environment<CrewInfoCore>#>)
////        OtherPlayerView(nsaid: nil)
//    }
//}
