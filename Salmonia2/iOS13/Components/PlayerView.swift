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
        VStack(alignment: .trailing) {
            HStack {
                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) {
                    URLImage(url: URL(string: user.imageUri)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                        .frame(width: 85, height: 85)
                }.buttonStyle(PlainButtonStyle())
                Text(user.nickname).modifier(Splatfont(size: 29)).frame(maxWidth: .infinity)
            }.padding(.horizontal, 10)
            Text("Overview".localized).foregroundColor(.cOrange).font(.custom("Splatfont", size: 21)).frame(maxWidth: .infinity).frame(height: 32).background(Color.cDarkGray).padding(.bottom, 5)
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
            }
            .padding(.bottom, 5)
            .modifier(Splatfont(size: 18))
            .padding(.horizontal, 10)
            CrewSearch
        }
    }
    
    private var CrewSearch: some View {
        NavigationLink(destination: CrewListView().environmentObject(SalmoniaUserCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cDarkGray)
                    Text("Favorite Crew").font(.custom("Splatfont2", size: 20))
                }
            }
            .frame(maxWidth: 240)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
