//
//  Realm.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import RealmSwift
import Combine
import CryptoSwift

class SalmoniaUserRealm: Object {
    
    @objc dynamic var api_token: String? = nil // Access token from Salmon Stats
    @objc dynamic var isImported: Bool = false
    @objc dynamic var isPurchase: Bool = false
    @objc dynamic var isDevelop: Bool = false
    @objc dynamic var isVersion: String = "1.9.0"
    dynamic var isUnlock = List<Bool>()
    dynamic var account = List<UserInfoRealm>()
    dynamic var favuser = List<CrewInfoRealm>()
    
    let placeholder: [Bool] = [false, false, false, false]
    
    convenience required init(isUnlock: [Bool]) {
        self.init()
        self.isUnlock.append(objectsIn: isUnlock)
    }
}

class UserInfoRealm: Object {
    
    @objc dynamic var name: String = "" // username from SplatNet2
    @objc dynamic var image: String = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/56a95fe848fd7f41" // userimage url from SplatNet2
    @objc dynamic var nsaid: String = "" // data-nsa-id from SplatNet2
    @objc dynamic var iksm_session: String? = nil // Access token for SplatNet2
    @objc dynamic var session_token: String? = nil // Session token to generate iksm_session
    @objc dynamic var job_num: Int = 0
    @objc dynamic var ikura_total: Int = 0
    @objc dynamic var golden_ikura_total: Int = 0
    @objc dynamic var isActive: Bool = false

    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class CrewInfoRealm: Object {
    
    @objc dynamic var name: String? // username from SplatNet2
    @objc dynamic var image: String? // userimage url from SplatNet2
    @objc dynamic var nsaid: String = "" // data-nsa-id from SplatNet2
    @objc dynamic var job_num: Int = 0
    @objc dynamic var ikura_total: Int = 0
    @objc dynamic var golden_ikura_total: Int = 0
    @objc dynamic var boss_defeated: Int = 0
    @objc dynamic var dead_count: Int = 0
    @objc dynamic var help_count: Int = 0
    let evalValue = RealmOptional<Double>()
    let srpower = RealmOptional<Double>()
    @objc dynamic var isFav: Bool = false
    @objc dynamic var lastUpdated: Int = 0
    
    convenience required init(name: String, image: String, nsaid: String) {
        self.init()
        self.name = name
        self.image = image
        self.nsaid = nsaid
    }

    override static func primaryKey() -> String? {
        return "nsaid"
    }
}

class CoopResultsRealm: Object {
    
    @objc dynamic var nsaid: String?
    let job_id = RealmOptional<Int>() // SplatNet2用のID
    @objc dynamic var stage_id: Int = 5000
    let salmon_id = RealmOptional<Int>() // SalmonStats用のID
    let grade_point = RealmOptional<Int>()
    let grade_id = RealmOptional<Int>()
    let grade_point_delta = RealmOptional<Int>()
    let failure_wave = RealmOptional<Int>()
    @objc dynamic var danger_rate: Double = 0.0
    @objc dynamic var play_time : Int = 0
    @objc dynamic var end_time: Int = 0
    @objc dynamic var start_time: Int = 0
    @objc dynamic var golden_eggs: Int = 0
    @objc dynamic var power_eggs: Int = 0
    @objc dynamic var failure_reason: String?
    @objc dynamic var is_clear: Bool = false
    dynamic var boss_counts = List<Int>()
    dynamic var boss_kill_counts = List<Int>()
    dynamic var wave = List<WaveDetailRealm>()
    dynamic var player = List<PlayerResultsRealm>()
    
    override static func primaryKey() -> String? {
        return "play_time"
    }
    
    override static func indexedProperties() -> [String] {
        return ["start_time"]
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
}

class WaveDetailRealm: Object {
    
    @objc dynamic var event_type: String?
    @objc dynamic var water_level: String?
    @objc dynamic var golden_ikura_num: Int = 0
    @objc dynamic var golden_ikura_pop_num: Int = 0
    @objc dynamic var quota_num: Int = 0
    @objc dynamic var ikura_num: Int = 0
    let result = LinkingObjects(fromType: CoopResultsRealm.self, property: "wave")
    
    override static func indexedProperties() -> [String] {
        return ["golden_ikura_num"]
    }
}

class PlayerResultsRealm: Object {
    
    @objc dynamic var name: String?
    @objc dynamic var nsaid: String?
    @objc dynamic var dead_count: Int = 0
    @objc dynamic var help_count: Int = 0
    @objc dynamic var golden_ikura_num: Int = 0
    @objc dynamic var ikura_num: Int = 0
    @objc dynamic var  special_id: Int = 0
    dynamic var boss_kill_counts = List<Int>()
    dynamic var weapon_list = List<Int>()
    dynamic var special_counts = List<Int>()
    let result = LinkingObjects(fromType: CoopResultsRealm.self, property: "player")
//    let nsaid = LinkingObjects(fromType: CrewInfoRealm.self, property: "nsaid")
    
    static func getids() -> [String] {
        guard let realm = try? Realm() else { return [] }
        return Array(Set(realm.objects(PlayerResultsRealm.self).map({ $0.nsaid! })))
    }
    
    override static func indexedProperties() -> [String] {
        return ["nsaid"]
    }
}

extension PlayerResultsRealm {
    var imageUri: String {
        return realm?.objects(CrewInfoRealm.self).filter("nsaid=%@", self.nsaid!).first?.image ?? "https://raw.githubusercontent.com/tkgstrator/Salmonia2/master/Salmonia2/Assets.xcassets/Default.imageset/default-1.png"
    }
}

class CoopShiftRealm: Object {
    
    @objc dynamic var start_time: Int = 0
    @objc dynamic var end_time: Int = 0
    @objc dynamic var stage_id: Int = 0
    @objc dynamic var rare_weapon: Int = 0
    dynamic var weapon_list = List<Int>()
//    dynamic var records = List<WaveRecordsRealm>()
    
    override static func primaryKey() -> String? {
        return "start_time"
    }
}

class WaveRecordsRealm: Object {
    @objc dynamic var job_id = 0
    @objc dynamic var water_level = 0
    @objc dynamic var event_type = 0
    @objc dynamic var start_time = 0
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var ikura_num = 0
    @objc dynamic var ukey = Int()
    @objc dynamic var sash: String? = nil
//    let shift = LinkingObjects(fromType: CoopShiftRealm.self, property: "records")
    
    func configure(tide: Int, event: Int, start_time: Int) {
        self.start_time = start_time
        self.water_level = tide
        self.event_type = event
        self.ukey = self.water_level * 10 + self.event_type
        self.sash = String(start_time + ukey).sha256()
    }
    
    convenience required init(_ job_id: Int, _ start_time: Int, _ water_level: Int, _ event_type:Int, _ golden_ikura_num: Int) {
        self.init()
        self.job_id = job_id
        self.golden_ikura_num = golden_ikura_num
        configure(tide: water_level, event: event_type, start_time: start_time)
    }
    
    override static func primaryKey() -> String? {
        return "sash"
    }

}

class SalmonRecordsRealm: Object {
    @objc dynamic var stage_id = 0
    @objc dynamic var start_time = 0
    @objc dynamic var water_level = 0
    @objc dynamic var event_type = 0
    @objc dynamic var golden_ikura_num = 0
    @objc dynamic var ukey = Int()
    @objc dynamic var sash: String? = nil
    
    func configure(tide: Int, event: Int, start_time: Int) {
        self.water_level = tide
        self.event_type = event
        self.start_time = start_time
        self.ukey = self.water_level * 10 + self.event_type
        self.sash = String(stage_id + ukey).sha256()
    }
    
    override static func primaryKey() -> String? {
        return "sash"
    }
}
