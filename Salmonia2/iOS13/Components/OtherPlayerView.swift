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
    @State var isFav: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                //                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) {
                //                    URLImage(URL(string: player.imageUri)!,
                //                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                //                        .frame(width: 80, height: 80)
                //                }.buttonStyle(PlainButtonStyle())
                Text(player.nickname).modifier(Splatfont(size: 28)).frame(maxWidth: .infinity)
            }
            Text("Overview").foregroundColor(.orange).modifier(Splatfont(size: 20))
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(player.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                    HStack {
                        Text("\(player.golden_ikura_total)").foregroundColor(.yellow)
                        Text("/")
                        Text("\(player.ikura_total)").foregroundColor(.red)
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
        print(isFav)
        switch isFav {
        case true:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "star.fill") })
        case false:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "star.fill").foregroundColor(.gray) })
        }
    }
    
    private func onToggleFav() {
        isFav.toggle()
        guard let realm = try? Realm() else { return }
        try! realm.write {
            player.user.isFav = isFav
        }
    }
}

//struct OtherPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherPlayerView(player: <#Environment<CrewInfoCore>#>)
////        OtherPlayerView(nsaid: nil)
//    }
//}
