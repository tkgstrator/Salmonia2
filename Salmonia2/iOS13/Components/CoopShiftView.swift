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
        VStack(alignment: .trailing, spacing: 0) {
            Text("Shift Schedule").foregroundColor(.cOrange).modifier(Splatfont(size: 20)).frame(maxWidth: .infinity).frame(height: 32).background(Color.cDarkGray).padding(.bottom, 8)
            ForEach(phases.data.indices, id:\.self) { idx in
                NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phases.data[idx].start_time)).environmentObject(SalmoniaUserCore())) {
                    CoopShiftStack(phase: $phases.data[idx]).padding(.horizontal, 10)
                }.buttonStyle(PlainButtonStyle())
            }
            CoopShift
        }
    }
    
    var CoopShift: some View {
        NavigationLink(destination: PastCoopShiftView().environmentObject(CoopShiftCore())) {
            HStack {
                ZStack {
                    Image("CoopBar")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.cDarkGray)
                    Text("Coop Shift Rotation").font(.custom("Splatfont2", size: 20))
                }
            }
            .frame(maxWidth: 240)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct CoopShiftStack: View {
    @Binding var phase: CoopShiftRealm
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!) { image in image.resizable().frame(width: 27, height: 18)}
                Text(UnixTime.dateFromTimestamp(phase.start_time)).frame(height: 18)
                Text(verbatim: "-").frame(height: 18)
                Text(UnixTime.dateFromTimestamp(phase.end_time)).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(url: URL(string: (StageType(stage_id: phase.stage_id)?.image_url)!)!) { image in image.resizable().frame(width: 112, height: 63) }.clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
                HStack {
                    ForEach(phase.weapon_list, id:\.self) { weapon in
                        //                        Text(WeaponType(weapon_id: weapon)!.image_url)
                        URLImage(url: WeaponType(weapon_id: weapon)!.image_url) { image in image.resizable().frame(width: 40, height: 40) }
                    }
                    // 緑ランダムの場合は最後にクマブキ表示
                    //                    if user.is_unlock && phase["WeaponSets"][3].intValue == -1 {
                    //                        URLImage(URL(string: ImageURL.weapon(self.phase["RareWeaponID"].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    //                    }
                }.frame(maxWidth: .infinity)
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
