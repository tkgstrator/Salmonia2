//
//  CoopShiftView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-26.
//

import SwiftUI
import RealmSwift
import URLImage

struct CoopShiftView: View {
    @EnvironmentObject var phases: CoopShiftCore
    
    var body: some View {
        ForEach(phases.data.indices, id:\.self) { idx in
            ZStack {
                NavigationLink(destination: ShiftStatsView(stats: UserStatsCore(start_time: phases.data[idx].start_time))) {
                    EmptyView()
                }
                .opacity(0.0)
                CoopShiftStack(phase: phases.data[idx], isRareWeapon: $phases.isUnlockWeapon)
            }
        }
    }
    
    var CoopShift: some View {
        NavigationLink(destination: PastCoopShiftView()) {
            Text("Coop Shift Rotation")
                .modifier(Splatfont2(size: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//struct CoopShiftStack: View {
//    @Binding var phase: CoopShiftRealm
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
////                URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!) { image in image.resizable().frame(width: 27, height: 18)}
//                Text(UnixTime.dateFromTimestamp(phase.start_time))
//                Text(verbatim: "-")
//                Text(UnixTime.dateFromTimestamp(phase.end_time))
//                Spacer()
//            }
//            HStack {
//                URLImage(url: URL(string: (StageType(stage_id: phase.stage_id)?.image_url)!)!) { image in image.resizable().frame(width: 96, height: 54) }.clipShape(RoundedRectangle(cornerRadius: 8.0))
//                Spacer()
//                HStack {
//                    ForEach(phase.weapon_list, id:\.self) { weapon in
//                        URLImage(url: WeaponType(weapon_id: weapon)!.image_url) { image in image.resizable().frame(width: 40, height: 40) }
//                    }
//                    // 緑ランダムの場合は最後にクマブキ表示
//                    //                    if user.is_unlock && phase["WeaponSets"][3].intValue == -1 {
//                    //                        URLImage(URL(string: ImageURL.weapon(self.phase["RareWeaponID"].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
//                    //                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
//        }
//        .frame(height: 100)
//        .font(.custom("Splatfont2", size: 16))
//    }
//}

struct CoopShiftView_Previews: PreviewProvider {
    static var previews: some View {
        CoopShiftView()
    }
}
