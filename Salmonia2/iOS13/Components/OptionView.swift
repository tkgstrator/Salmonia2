//
//  OptionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-09.
//

import SwiftUI
//import Combine
import URLImage
import RealmSwift

struct OptionView: View {
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Options").foregroundColor(.cOrange).modifier(Splatfont(size: 20)).frame(maxWidth: .infinity).frame(height: 32).background(Color.cDarkGray)
//            WaveSearch
            CrewSearch
//            CoopShift
        }
    }
    
    private var WaveSearch: some View {
        NavigationLink(destination: WaveCollectionView().environmentObject(WaveResultCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cGray)
                    Text("Wave Search").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var CoopShift: some View {
        NavigationLink(destination: PastCoopShiftView().environmentObject(CoopShiftCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cGray)
                    Text("Coop Shift Rotation").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
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
                    Text("Favorite Crew").font(.custom("Splatfont2", size: 22))
                }
            }
            .frame(maxWidth: 300)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}





struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView()
    }
}
