//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-26.
//

import SwiftUI
import URLImage

struct CoopShiftView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 27, height: 18)})
//                Text(Unixtime(interval: phase["StartDateTime"].intValue)).frame(height: 18)
                Text(verbatim: "-").frame(height: 18)
//                Text(Unixtime(interval: phase["EndDateTime"].intValue)).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(SP2Map.getURL(5000, 0), content: {$0.image.resizable().frame(width: 112, height: 63)
                }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
//                HStack {
//                    ForEach((phase["WeaponSets"].arrayObject as! [Int]).indices, id:\.self) { idx in
//                        URLImage(URL(string: ImageURL.weapon(self.phase["WeaponSets"][idx].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
//                    }
//                    // 緑ランダムの場合は最後にクマブキ表示
//                    if user.is_unlock && phase["WeaponSets"][3].intValue == -1 {
//                        URLImage(URL(string: ImageURL.weapon(self.phase["RareWeaponID"].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
//                    }
//                }.frame(maxWidth: .infinity)
            }.frame(height: 63)
        }.frame(height: 100)
            .font(.custom("Splatfont2", size: 18))
    }
}

struct CoopShiftView_Previews: PreviewProvider {
    static var previews: some View {
        CoopShiftView()
    }
}
