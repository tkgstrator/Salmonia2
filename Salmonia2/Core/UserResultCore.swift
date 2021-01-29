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

    @Published var data: [UserCoopResult] = []
    
    func update(_ golden_eggs: Int = 0, _ stage: [Int]) {
        let start_time: [Int] = Array(Set(realm.objects(CoopResultsRealm.self).filter("stage_id IN %@ AND golden_eggs>=%@", stage, golden_eggs).map({ $0.start_time }))).sorted(by: >)
        data = start_time.map({ UserCoopResult(start_time: $0, golden_eggs: golden_eggs) })
    }

    // シフトIDを指定せず初期化
    init() {
        // 変更があるたびに再読込するだけ
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            let start_time: [Int] = Array(Set(realm.objects(CoopResultsRealm.self).map({ $0.start_time }))).sorted(by: >)
            data = start_time.map({ UserCoopResult(start_time: $0) })
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    struct UserCoopResult {
        var start_time: Int
        var phase: CoopShiftRealm
        var results: RealmSwift.Results<CoopResultsRealm>
        
        init(start_time: Int, golden_eggs: Int = 0) {
            self.start_time = start_time
            phase = realm.objects(CoopShiftRealm.self).filter("start_time=%@", start_time).first!
            results = realm.objects(CoopResultsRealm.self).filter("start_time=%@ AND golden_eggs>=%@", start_time, golden_eggs).sorted(byKeyPath: golden_eggs == 0 ? "play_time" : "golden_eggs", ascending: false)
        }
    }
}
