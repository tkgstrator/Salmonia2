//
//  WeaponCollectionView.swift
//  Salmonia2
//
//  Created by Devonly on 2021/02/10.
//

import SwiftUI
import URLImage

struct WeaponCollectionView: View {
//    @ObservedObject var stats: UserStatsCore
    var weapon_lists: [[WeaponList]]
//    @State var weapons: [[WeaponType]] = WeaponType.allCases.filter({ $0.weapon_id! >= 0 && $0.weapon_id! < 9999 }).sorted(by: { a, b -> Bool in return a.weapon_id! < b.weapon_id! }).chunked(by: 5)
    
    var body: some View {
        ScrollView {
            ForEach(weapon_lists, id:\.self) { weapon_list in
                HStack(spacing: 10) {
                    ForEach(weapon_list, id:\.self) { weapon in
                        ZStack(alignment: .bottomLeading) {
                            switch weapon.count {
                            case nil:
                                URLImage(url: weapon.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 50).grayscale(0.99).opacity(0.5) }
                            default:
                                URLImage(url: weapon.image_url) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 50) }
                                    .disabled(true)
                                Circle().fill(Color.white).frame(width: 20, height: 20)
                                    .overlay(Text("\(weapon.count!)").foregroundColor(.black))
//                                Text("\(weapon.count!)")
//                                    .rainbowAnimation(true)
//                                    .padding()
//                                    .overlay(Circle().fill(Color.white).frame(width: 20, height: 20))
//                                    .background(Circle().stroke(Color.white, lineWidth: 5).padding(5))
                            }
                        }
                        .frame(maxWidth: 100)
                        .font(.custom("Splatfont2", size: 14))
                    }
                }
            }
        }
        .navigationTitle("TITLE_RANDOM_WEAPON")
    }
}

//struct WeaponCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeaponCollectionView()
//    }
//}
