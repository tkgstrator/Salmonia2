//
//  UserResultCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class UserResultCore: ObservableObject {
    private var token: NotificationToken?

    @Published var results:  Results<CoopResultsRealm> = realm.objects(CoopResultsRealm.self)
    
    func update(_ golden_eggs: Int, _ stage: [Int]) {
        // 金イクラ数指定が0のときはplay_timeでソーティングする
        if golden_eggs == 0 {
            results = realm.objects(CoopResultsRealm.self).filter("stage_id IN %@", stage).sorted(byKeyPath: "play_time", ascending: false)
        } else {
            results = realm.objects(CoopResultsRealm.self).filter("golden_eggs>=%@ AND stage_id IN %@", golden_eggs, stage).sorted(byKeyPath: "golden_eggs")
        }
    }
    
    // シフトIDを指定して初期化
    init(start_time: Int) {
        // 変更があるたびに再読込するだけ
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            results = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time).sorted(byKeyPath: "play_time", ascending: false)
        }
    }
    
    // シフトIDを指定せず初期化
    init() {
        // 変更があるたびに再読込するだけ
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            results = realm.objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false)
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
