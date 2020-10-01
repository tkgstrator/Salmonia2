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
    @State var phases: [CoopShiftRealm] = []
    
    init() {
        guard let realm = try? Realm() else { return }
        let current_time: Int = Int(Date().timeIntervalSince1970)
//        guard let start_time: Int = realm.objects(CoopShiftRealm.self).filter("end_time<=%@", current_time).last?.start_time else { return }
        guard let end_time: Int = realm.objects(CoopShiftRealm.self).filter("end_time<=%@", current_time).sorted(byKeyPath: "start_time", ascending: true).last?.start_time else { return }
        let phases = realm.objects(CoopShiftRealm.self).filter("start_time>=%@", end_time).sorted(byKeyPath: "start_time", ascending: true).prefix(3)
        _phases = State(initialValue: Array(phases))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Shift Schedule").foregroundColor(.orange).modifier(Splatfont(size: 20))
            ForEach(phases.indices, id:\.self) { idx in
                NavigationLink(destination: ShiftStatsView().environmentObject(UserStatsCore(start_time: phases[idx].start_time))) {
                    CoopShiftStack(phase: $phases[idx])
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
}

private struct CoopShiftStack: View {
    @Binding var phase: CoopShiftRealm
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 27, height: 18)})
                Text(UnixTime.dateFromTimestamp(phase.start_time)).frame(height: 18)
                Text(verbatim: "-").frame(height: 18)
                Text(UnixTime.dateFromTimestamp(phase.end_time)).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(FImage.getURL(phase.stage_id, 0), content: {$0.image.resizable().frame(width: 112, height: 63)
                }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
                HStack {
                    ForEach(phase.weapon_list, id:\.self) { weapon in
                        URLImage(FImage.getURL(weapon, 1), content: {$0.image.resizable().frame(width: 40, height: 40)})
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
