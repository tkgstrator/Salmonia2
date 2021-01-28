//
//  AchievementCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-10.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class AchievementCore: ObservableObject {
    
    private var token: NotificationToken?
    @Published var boss_counts: [BossStats] = []
    @Published var special_clear_ratio: [SpecialStats] = []
    
    init() {
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            let results = realm.objects(CoopResultsRealm.self)
            boss_counts = [] // 初期化
            
            var counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            var kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
            
            for result in results {
                counts = Array(zip(counts, result.boss_counts).map({ $0.0 + $0.1 }))
                kill_counts = Array(zip(kill_counts, result.player[0].boss_kill_counts).map({ $0.0 + $0.1 }))
            }
            for (idx, boss_id) in [3, 6, 9, 12, 13, 14, 15, 16, 21].enumerated() {
                boss_counts.append(BossStats(boss_id, counts[idx], kill_counts[idx]))
            }
            
            if results.count != 0 {
                special_clear_ratio = [] // 初期化
                for special_id in [2, 7, 8, 9] {
                    let total = results.filter({ $0.player[0].special_id == special_id}).count
                    let clear = results.filter({ $0.player[0].special_id == special_id && $0.is_clear == true}).count
                    special_clear_ratio.append(SpecialStats(special_id, total, clear))
                }
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

struct SpecialStats: Hashable {
    var name: String?
    var count: Int
    var clear: Int
    var ratio: Double?
    
    init(_ id: Int, _ count: Int, _ clear: Int) {
        switch id {
        case 2:
            self.name = "Bomb Launcher"
        case 7:
            self.name = "Sting Ray"
        case 8:
            self.name = "Inkjet"
        case 9:
            self.name = "Splashdown"
        default:
            break
        }
        self.count = count
        self.clear = clear
        if count != 0 {
            self.ratio = Double(clear) / Double(count)
        }
    }
}

struct BossStats: Hashable {
    var name: String
    var boss_count: Int
    var boss_kill_count: Int
    
    init(_ id: Int, _ appear: Int, _ kill: Int) {
        name = (BossType.init(boss_id: id)?.boss_name!)!
        boss_count = appear
        boss_kill_count = kill
    }
}
