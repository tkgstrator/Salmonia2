//
//  OverView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import Combine
import RealmSwift

class ShiftResultsModel: ObservableObject {
    public var stats: Results<ShiftResultsRealm> = ShiftResultsRealm.all().sorted(byKeyPath: "start_time", ascending: false)
    public var objectWillChange: ObservableObjectPublisher = .init()
    private var notificationTokens: [NotificationToken] = []
    
    // 最初にDBから読み込むのだが、一度しか呼ばれないので発火しない
    init() {
        notificationTokens.append(stats.observe { _ in
            self.objectWillChange.send()
            })
    }
}

struct OverViewColumn: View {
    private var title: String
    private var value: String
    
    init(title: String, value: Any?) {
        self.title = title
        self.value = value.string
    }
    
    var body: some View {
        HStack {
            Text(self.title).font(.custom("Splatfont2", size: 20)).frame(alignment: .center)
            Spacer()
            Text(self.value).font(.custom("Splatfont2", size: 20)).frame(alignment: .center)
        }
    }
}

struct OverView: View {
    @ObservedObject var realm = ShiftResultsModel()
    
    var body: some View {
        ScrollView {
            OverViewColumn(title: "JOB NUM", value: realm.stats.first?.job_num)
            OverViewColumn(title: "CLEAR RATE", value: realm.stats.first?.clear_num)
            OverViewColumn(title: "GRADE POINT", value: realm.stats.first?.grade_point)
            OverViewColumn(title: "GRIZZCO POINT", value: realm.stats.first?.kuma_point_total)
            OverViewColumn(title: "DEAD COUNT", value: realm.stats.first?.dead_total)
            OverViewColumn(title: "HELP COUNT", value: realm.stats.first?.help_total)
            OverViewColumn(title: "TEAM GOLDEN EGGS", value: realm.stats.first?.team_golden_ikura_total)
            OverViewColumn(title: "TEAM POWER EGGS", value: realm.stats.first?.team_ikura_total)
            OverViewColumn(title: "MY GOLDEN EGGS", value: realm.stats.first?.my_golden_ikura_total)
            OverViewColumn(title: "MY POWER EGGS", value: realm.stats.first?.my_ikura_total)
        }
    }
}


//struct OverView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverView()
//    }
//}
