//
//  Realm.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-24.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import RealmSwift
import CryptoSwift

class UserInfoRealm: Object {
    @objc dynamic var name: String? // username from SplatNet2
    @objc dynamic var image: String? // userimage url from SplatNet2
    @objc dynamic var nsaid: String?  // data-nsa-id from SplatNet2
    @objc dynamic var api_token: String? = nil // Access token from Salmon Stats
    @objc dynamic var iksm_session: String? = nil // Access token for SplatNet2
    @objc dynamic var session_token: String? = nil // Session token to generate iksm_session
    @objc dynamic var is_imported: Bool = false // imported flag for Salmon Stats
    @objc dynamic var is_develop: Bool = false // developed flag for Salmon Stats
    @objc dynamic var is_unlock: Bool = false // unlock grizzco weapon flag for Salmon Stats

    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class CoopCardRealm: Object, Codable {
    @objc dynamic var nsaid: String?
    let job_num = RealmOptional<Int>()
    let ikura_total = RealmOptional<Int>()
    let golden_ikura_total = RealmOptional<Int>()
    let kuma_point = RealmOptional<Int>()
    let kuma_point_total = RealmOptional<Int>()
    let help_total = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class ShiftResultsRealm: Object {
    // ここもnilを許容するように変更するか検討しよう...
    @objc dynamic var start_time = 0
    @objc dynamic var nsaid = ""
    @objc dynamic var salmon_rate: Double = 0.0
    @objc dynamic var sash: String? = nil
    @objc dynamic var job_num = 0
    @objc dynamic var clear_num = 0
    @objc dynamic var grade_point = 0
    @objc dynamic var kuma_point_total = 0
    @objc dynamic var dead_total = 0
    @objc dynamic var help_total = 0
    @objc dynamic var team_golden_ikura_total = 0
    @objc dynamic var my_golden_ikura_total = 0
    @objc dynamic var team_ikura_total = 0
    @objc dynamic var my_ikura_total = 0
    dynamic var weapons = List<Int>()
    dynamic var failure_counts = List<Int>()
    
    override static func primaryKey() -> String? {
        return "sash"
    }
}

class CoopResultsRealm: Object {
    @objc dynamic var nsaid = ""
    let job_id = RealmOptional<Int>() // SplatNet2用のID
    let stage_id = RealmOptional<Int>()
    let salmon_id = RealmOptional<Int>() // SalmonStats用のID
    let grade_point = RealmOptional<Int>()
    let grade_id = RealmOptional<Int>()
    let grade_point_delta = RealmOptional<Int>()
    let failure_wave = RealmOptional<Int>()
    @objc dynamic var danger_rate = 0.0
    @objc dynamic var play_time = 0
    @objc dynamic var end_time = 0
    @objc dynamic var start_time = 0
    @objc dynamic var golden_eggs = 0
    @objc dynamic var power_eggs = 0
    @objc dynamic var failure_reason: String?
    @objc dynamic var is_clear: Bool = false
    dynamic var boss_counts = List<Int>()
    dynamic var boss_kill_counts = List<Int>()
    dynamic var wave = List<WaveDetailRealm>()
    dynamic var player = List<PlayerResultsRealm>()
    
    // 多分落ちないはず
    private static var realm = try! Realm()
    
    // Salmon Statsから取得したデータを変換するため
    // ステージIDが設定されてないシフト
    static func gettime() -> [Int] {
        return Array(Set(realm.objects(CoopResultsRealm.self).filter({ $0.stage_id.value == nil}).map({ $0.start_time })))
    }
    
    func getSP() -> [[Int]] {
        var usage: [[Int]] = []
        for (wave, _) in self.wave.enumerated() {
            var tmp: [Int] = []
            for player in self.player {
                let special_id: Int = player.special_id
                let count: Int = player.special_counts[wave]
                
                switch count {
                case 1:
                    tmp.append(special_id)
                case 2:
                    tmp.append(special_id)
                    tmp.append(special_id)
                default:
                    break
                }
            }
            usage.append(tmp)
        }
        return usage
    }

    override static func primaryKey() -> String? {
        return "play_time"
    }
    
    override static func indexedProperties() -> [String] {
        return ["start_time"]
    }
}

class WaveDetailRealm: Object {
    @objc dynamic var event_type = ""
    @objc dynamic var water_level = ""
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var golden_ikura_pop_num = 0
    @objc dynamic var quota_num = 0
    @objc dynamic var ikura_num = 0
    @objc dynamic var start_time = 0

    let result = LinkingObjects(fromType: CoopResultsRealm.self, property: "wave")
}


class PlayerResultsRealm: Object {
    @objc dynamic var dead_count = 0
    @objc dynamic var help_count = 0
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var ikura_num = 0
    @objc dynamic var name: String?
    @objc dynamic var nsaid = ""
    @objc dynamic var special_id = 0
    dynamic var boss_kill_counts = List<Int>()
    dynamic var weapon_list = List<Int>()
    dynamic var special_counts = List<Int>()
    
    let result = LinkingObjects(fromType: CoopResultsRealm.self, property: "player")
    
    static func getids() -> [String] {
        guard let realm = try? Realm() else { return [] }
        return Array(Set(realm.objects(PlayerResultsRealm.self).map({ $0.nsaid })))
    }
}

class CrewInfoRealm: Object {
    @objc dynamic var name: String? // username from SplatNet2
    @objc dynamic var image: String? // userimage url from SplatNet2
    @objc dynamic var nsaid: String?  // data-nsa-id from SplatNet2

    override static func primaryKey() -> String? {
        return "nsaid"
    }
    
    override static func indexedProperties() -> [String] {
        return ["nsaid"]
    }
}
