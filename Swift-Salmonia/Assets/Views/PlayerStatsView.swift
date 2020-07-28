//
//  PlayerStatsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine

// こんなことせんでも描画のたびに再計算でいいのでは？そんな負荷かからんやろ
class CoopResultsModel: ObservableObject {
    public var stats: Results<CoopResultsRealm> = CoopResultsRealm.all().sorted(byKeyPath: "start_time", ascending: false)
    public var objectWillChange: ObservableObjectPublisher = .init()
    private var notificationTokens: [NotificationToken] = []
    
    // 最初にDBから読み込むのだが、一度しか呼ばれないので発火しない
    init() {
        notificationTokens.append(stats.observe { _ in
            self.objectWillChange.send()
            })
    }
}

struct StatsColumn: View {
    private var title = ""
    private var value = ""
    
    init(title: String, value: Any?) {
        self.title = title
        self.value = value.string
    }
    
    var body: some View {
        HStack {
            Text(self.title)
            Spacer()
            Text(self.value)
        }
    }
}


struct PlayerStatsView: View {
    @State var shift_id: Int?
    
    var body: some View {
        List {
            StatsColumn(title: "JOB NUM", value: shift_id)
            
        }.onAppear(){
            let realm = try? Realm()
            self.shift_id = realm?.objects(CoopResultsRealm.self).sorted(byKeyPath: "start_time", ascending: false).first?.start_time
        }
    }
}

struct PlayerStatsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatsView()
    }
}
