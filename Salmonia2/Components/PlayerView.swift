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
            VStack(spacing: 0) {
                HStack {
                    URLImage(url: URL(string: user.imageUri)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                        .frame(width: 60, height: 60)
                    Text(user.nickname).modifier(Splatfont(size: 20)).frame(maxWidth: .infinity)
                }
                NavigationLink(destination: ResultCollectionView(core: UserResultCore())) {
                    Text("Job results").modifier(Splatfont2(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Jobs")
                        .modifier(Splatfont(size: 18))
                    Text("\(user.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs")
                        .modifier(Splatfont(size: 18))
                    HStack {
                        Text("\(user.golden_ikura_total)").foregroundColor(.yellow)
                        Text("/")
                        Text("\(user.ikura_total)").foregroundColor(.red)
                    }
                }
                Spacer()
            }
            .font(.custom("Splatfont", size: 18))
            .padding(.horizontal, 10)
            CrewSearch
        }
    }
    
    private var CrewSearch: some View {
        NavigationLink(destination: CrewListView()) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cDarkGray)
                    Text("Favorite Crew")
                        .modifier(Splatfont2(size: 20))
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
