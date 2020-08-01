//
//  Struct.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-31.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import RealmSwift

// ステージごとの記録を保持する構造体
struct StageRecords: Hashable {
    public var grade_point: Int?
    public var team_golden_eggs: Int?
    public var my_golden_eggs: Int?
    
    public var data: [Int : [Int?]] = [
        0: [nil, nil, nil],
        1: [nil, nil, nil],
        2: [nil, nil, nil],
        3: [nil, nil, nil],
        4: [nil, nil, nil],
        5: [nil, nil, nil],
        6: [nil, nil, nil]
    ]
    
    init() {
    }
    
    // データを上書きする処理
    mutating func set(event: Int, tide: Int, value: Int?) {
        data[tide]?[event] = value
    }
}

// リザルトの概要情報を保持する構造体（名前がダサいので変えたい）
struct ResultCollection: Hashable {
    public var job_id: Int?
    public var danger_rate: Double?
    public var is_clear: Bool?
    public var weapons: RealmSwift.List<Int>
    public var special: Int?
    public var golden_eggs: Int?
    public var power_eggs: Int?
    
    init(job_id: Int?, danger_rate: Double?, is_clear: Bool?, weapons: List<Int>, special: Int?, golden_eggs: Int?, power_eggs: Int?) {
        self.job_id = job_id
        self.danger_rate = danger_rate
        self.is_clear = is_clear
        self.weapons = weapons
        self.special = special
        self.golden_eggs = golden_eggs
        self.power_eggs = power_eggs
    }
}

// ユーザ情報を保持する構造体（自分と他人で全く同じものを使えるようにしたいよね）

struct UserInformation: Hashable {
    public var nsaid: String?
    public var username: String?
    public var imageUri: String?
    public var iksm_session: String?
    public var session_token: String?
    public var api_token: String?
    public var overview: PlayerOverview = PlayerOverview()
    
    // ここちょいダサい
    public var records: [StageRecords] = [StageRecords(), StageRecords(), StageRecords(), StageRecords(), StageRecords(), StageRecords()]
    
    init() {
        
    }
    
    init(name: String?, url: String?, iksm_session: String?, session_token: String?, api_token: String?) {
        self.username = name
        self.imageUri = url
        self.iksm_session = iksm_session
        self.session_token = session_token
        self.api_token = api_token
    }
}

// UserInformationで使っているプレイヤーの概要情報を保持する構造体
struct PlayerOverview: Hashable {
    public var job_count: Int?
    public var ikura_total: Int?
    public var golden_ikura_total: Int?
    public var kuma_point_total: Int?
    // 追加情報
    public var golden_eggs_ratio: Double?
    public var power_eggs_ratio: Double?
    public var defeated: Double?
    public var clear_wave: Double?
    public var clear_ratio: Double?
    
    init() {
        
    }
    
    init(job_count: Int?, ikura_total: Int?, golden_ikura_total: Int?, kuma_point_total: Int?) {
        self.job_count = job_count
        self.ikura_total = ikura_total
        self.golden_ikura_total = golden_ikura_total
        self.kuma_point_total = kuma_point_total
    }
}
