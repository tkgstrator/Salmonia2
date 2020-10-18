//
//  PlayerView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct PlayerView: View {
    @EnvironmentObject var user: UserInfoCore
    
    var body: some View {
        VStack {
            HStack {
                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) {
                    URLImage(URL(string: user.imageUri)!,
                             content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 80, height: 80)
                }
                //                .buttonStyle(PlainButtonStyle())
                Text(user.nickname).modifier(Splatfont(size: 28)).frame(maxWidth: .infinity)
            }.padding(.horizontal, 10)
            Text("Overview".localized).foregroundColor(.cOrange).font(.custom("Splatfont", size: 21)).frame(maxWidth: .infinity).background(Color.cDarkGray).padding(.bottom, 5)
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(user.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                    HStack {
                        Text("\(user.golden_ikura_total)").foregroundColor(.yellow)
                        Text("/")
                        Text("\(user.ikura_total)").foregroundColor(.red)
                    }
                }
                Spacer()
            }.padding(.bottom, 5)
            .modifier(Splatfont(size: 18))
            .padding(.horizontal, 10)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
