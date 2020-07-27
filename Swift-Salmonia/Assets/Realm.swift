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
    
    private static let realm = try! Realm()
    
    static func all() -> Results<UserInfoRealm>
    {
        realm.objects(UserInfoRealm.self)
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
    
    override static func primaryKey() -> String? {
        return "sash"
    }
}
