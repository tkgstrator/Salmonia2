//
//  ShiftRotationView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import URLImage

let response: JSON = try! JSON(data: NSData(contentsOfFile: Bundle.main.path(forResource: "formated_future_shifts", ofType:"json")!) as Data)
let lastid = response.filter({ $0.1["EndDateTime"].intValue < Int(Date().timeIntervalSince1970)}).last!.0

struct FutureShiftView: View {
    @State var current_time: Int = Int(Date().timeIntervalSince1970)
    @State var phases: [JSON] = response.filter({ Int($0.0)! >= Int(lastid)! }).map({ $0.1 }).prefix(3).map({ $0 })
    @State var start_time: [Int] = []
    
    init () {
        let start_time = phases.map({ $0["StartDateTime"].intValue })
        _start_time = State(initialValue: start_time)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Shift Schedule")
                .frame(height: 14)
                .foregroundColor(.orange)
                .font(.custom("Splatoon1", size: 20))
            ForEach(phases.indices) { idx in
                NavigationLink(destination: ShiftStatsView(start_time: self.$start_time[idx])) {
                    ShiftStack(phase: self.$phases[idx])
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct CompleteShiftView: View {
    @State var current_time: Int = Int(Date().timeIntervalSince1970)
    @State var phases: [JSON] = response.filter({ Int($0.0)! >= Int(lastid)! }).map({ $0.1 }).map({ $0 })
    @State var start_time: [Int] = []
    
    init () {
        let start_time = phases.map({ $0["StartDateTime"].intValue })
        _start_time = State(initialValue: start_time)
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        List {
            ForEach(phases.indices) { idx in
                ShiftStack(phase: self.$phases[idx])
            }
        }.navigationBarTitle("Future Rotation")
    }
}

// 他のビューから参照したくないのでprivateにする
private struct ShiftStack: View {
    @Binding var phase: JSON
    @ObservedObject var user = UserInfoCore()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 27, height: 18)})
                Text(Unixtime(interval: phase["StartDateTime"].intValue)).frame(height: 18)
                Text("-").frame(height: 18)
                Text(Unixtime(interval: phase["EndDateTime"].intValue)).frame(height: 18)
                Spacer()
            }.frame(height: 26)
            HStack {
                URLImage(URL(string: ImageURL.stage(phase["StageID"].intValue))!, content: {$0.image.resizable().frame(width: 112, height: 63)
                }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                Spacer()
                HStack {
                    ForEach((phase["WeaponSets"].arrayObject as! [Int]).indices, id:\.self) { idx in
                        URLImage(URL(string: ImageURL.weapon(self.phase["WeaponSets"][idx].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    }
                    // 緑ランダムの場合は最後にクマブキ表示
                    if user.is_unlock && phase["WeaponSets"][3].intValue == -1 {
                        URLImage(URL(string: ImageURL.weapon(self.phase["RareWeaponID"].intValue))!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                    }
                }.frame(maxWidth: .infinity)
            }.frame(height: 63)
        }.frame(height: 100)
        .font(.custom("Splatfont2", size: 18))
    }
}

struct FutureShiftView_Previews: PreviewProvider {
    static var previews: some View {
        FutureShiftView()
    }
}
