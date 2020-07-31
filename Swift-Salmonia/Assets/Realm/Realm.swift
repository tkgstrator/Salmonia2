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
    @objc dynamic var name = "" // username from SplatNet2
    @objc dynamic var image = "" // userimage url from SplatNet2
    @objc dynamic var nsaid = "" // data-nsa-id from SplatNet2
    @objc dynamic var api_token: String? = nil // Access token from Salmon Stats
    @objc dynamic var iksm_session: String? = nil // Access token for SplatNet2
    @objc dynamic var session_token: String? = nil // Session token to generate iksm_session

    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class CoopCardRealm: Object {
    @objc dynamic var nsaid: String = ""
    @objc dynamic var job_num: Int = 0
    @objc dynamic var ikura_total: Int = 0
    @objc dynamic var golden_ikura_total: Int = 0
    @objc dynamic var kuma_point: Int = 0
    @objc dynamic var kuma_point_total: Int = 0
    @objc dynamic var help_total: Int = 0

    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class ShiftResultsRealm: Object {
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
    dynamic var failure_count = List<Int>()

    func configure(nsaid: String, start_time: Int) {
        self.nsaid = nsaid
        self.start_time = start_time
        self.sash = (nsaid + String(start_time)).sha256()
    }
    
    private static let realm = try! Realm()
    
    static func all() -> Results<ShiftResultsRealm>
    {
        realm.objects(ShiftResultsRealm.self)
    }
    
    override static func primaryKey() -> String? {
        return "sash"
    }
}

class CoopResultsRealm: Object {
    @objc dynamic var nsaid = ""
    @objc dynamic var job_id = 0
    @objc dynamic var stage_name = ""
    @objc dynamic var grade_point = 0
    @objc dynamic var grade_id = 0
    @objc dynamic var danger_rate = 0.0
    @objc dynamic var grade_point_delta = 0
    @objc dynamic var play_time = 0
    @objc dynamic var end_time = 0
    @objc dynamic var start_time = 0
    @objc dynamic var golden_eggs = 0
    @objc dynamic var power_eggs = 0
    @objc dynamic var job_result_failure_reason: String? = nil
    @objc dynamic var job_result_is_clear = false
    dynamic var appear = List<Int>()
    dynamic var defeat = List<Int>()
    let job_result_failure_wave = RealmOptional<Int>()
    dynamic var wave = List<WaveDetailRealm>()
    dynamic var player = List<PlayerResultsRealm>()
    
    override static func primaryKey() -> String? {
        return "play_time"
    }
}

class WaveDetailRealm: Object {
    @objc dynamic var event_type = ""
    @objc dynamic var water_level = ""
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var golden_ikura_pop_num = 0
    @objc dynamic var quota_num = 0
    @objc dynamic var ikura_num = 0
    @objc dynamic var shift_id = 0
    
    let id = LinkingObjects(fromType: CoopResultsRealm.self, property: "wave")
}

class PlayerResultsRealm: Object {
    @objc dynamic var dead_count = 0
    @objc dynamic var help_count = 0
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var ikura_num = 0
    @objc dynamic var name = ""
    @objc dynamic var nsaid = ""
    @objc dynamic var special_id = 0
    dynamic var defeat = List<Int>()
    dynamic var weapon = List<Int>()
    dynamic var special = List<Int>()
}
