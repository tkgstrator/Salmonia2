//
//  SalmoniaCore.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import Combine
import RealmSwift
import SwiftyJSON
import Alamofire

// ObserverdObjectクラスを持っているところ
class UserResultsCore: ObservableObject {
    private var token: NotificationToken?
//    private var realm = try! Realm().objects(CoopResultsRealm.self)
    private var core = try! Realm().objects(CoopResultsRealm.self)
    private var realm = try! Realm()

//    @Published var results = try! Realm().objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false)
    @Published var results = try! Realm().objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false)

    // 金イクラ数でフィルタリング
    func update(_ golden_eggs: Int) {
        results = realm.objects(CoopResultsRealm.self).filter("golden_eggs>=%@", golden_eggs).sorted(byKeyPath: "golden_eggs")
    }
    
    func filter(_ stage_id: Int) {
        results = realm.objects(CoopResultsRealm.self).filter("stage_id=%@", stage_id).sorted(byKeyPath: "play_time", ascending: false)
    }

    // ちょいダサい？
    init() {
        token = core.observe { _ in
            // データベースを再読込して上書きする
//            self.results = self.realm.sorted(byKeyPath: "play_time", ascending: false)
            self.results = self.realm.objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false)
        }
    }
}

class UserStatsCore: ObservableObject {
    private var token: NotificationToken?
    
    @Binding var start_time: Int
    @Published var job_num: Int?
    @Published var clear_ratio: Double?
    @Published var total_power_eggs: Int?
    @Published var total_golden_eggs: Int?
    @Published var total_grizzco_points: Int?
    @Published var max_grade_point: Int?
    @Published var max_team_power_eggs: Int?
    @Published var max_team_golden_eggs: Int?
    @Published var max_my_power_eggs: Int?
    @Published var max_my_golden_eggs: Int?
    @Published var max_defeated: Int?
    @Published var avg_clear_wave: Double?
    @Published var avg_crew_grade: Double?
    @Published var avg_team_power_eggs: Double?
    @Published var avg_team_golden_eggs: Double?
    @Published var avg_my_power_eggs: Double?
    @Published var avg_my_golden_eggs: Double?
    @Published var avg_defeated: Double?
    @Published var avg_rescue: Double?
    @Published var avg_dead: Double?
    
    init(start_time: Binding<Int>) {
        self._start_time = start_time
        token = try? Realm().objects(CoopResultsRealm.self).observe { _ in
            #if DEBUG
            guard let results = try? Realm().objects(CoopResultsRealm.self).filter("start_time=%@", 1596153600) else { return }
            guard let summary = try? Realm().objects(ShiftResultsRealm.self).filter("start_time=%@", 1596153600).first else { return }
            #else
            guard let results = try? Realm().objects(CoopResultsRealm.self).filter("start_time=%@", self.start_time) else { return }
            guard let summary = try? Realm().objects(ShiftResultsRealm.self).filter("start_time=%@", self.start_time).first else { return }
            #endif
            
            self.job_num = summary.job_num
            self.clear_ratio = Double(Double(results.lazy.filter("is_clear=%@", true).count) / Double(summary.job_num)).round(digit: 4)
            self.total_golden_eggs = summary.team_golden_ikura_total
            self.total_power_eggs = summary.team_ikura_total
            self.total_grizzco_points = summary.kuma_point_total
            self.max_grade_point = results.max(ofProperty: "grade_point")
            self.max_team_golden_eggs = results.max(ofProperty: "golden_eggs")
            self.max_team_power_eggs = results.max(ofProperty: "power_eggs")
            self.max_my_power_eggs = results.lazy.map({ $0.player[0].ikura_num }).max()
            self.max_my_golden_eggs = results.lazy.map({ $0.player[0].golden_ikura_num }).max()
            self.max_defeated = results.lazy.map({ $0.player[0].boss_kill_counts.reduce(0, +) }).max()
            self.avg_clear_wave = Double(Double(results.map({ ($0.failure_wave.value ?? 4) - 1}).reduce(0, +)) / Double(summary.job_num)).round(digit: 2)
            self.avg_crew_grade = (results.lazy.map({ 20 * $0.danger_rate + Double($0.grade_point_delta.value ?? 0) - Double($0.grade_point.value ?? 0) - 1600.0}).lazy.reduce(0.0, +) / Double(summary.job_num * 3)).round(digit: 2)
            self.avg_team_golden_eggs = Double(Double(summary.team_golden_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_team_power_eggs = Double(Double(summary.team_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_my_golden_eggs = Double(Double(summary.my_golden_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_my_power_eggs = Double(Double(summary.my_ikura_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_dead = Double(Double(summary.dead_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_rescue = Double(Double(summary.help_total) / Double(summary.job_num)).round(digit: 2)
            self.avg_defeated = Double((Double(results.map({ $0.player[0].boss_kill_counts.reduce(0, +) }).reduce(0, +)) / Double(summary.job_num))).round(digit: 2)
        }
    }
}

class UserCardCore: ObservableObject {
    private var token: NotificationToken?
    
    // カード情報
    @Published var job_num: Int?
    @Published var ikura_total: Int?
    @Published var golden_ikura_total: Int?
    @Published var kuma_point: Int?
    @Published var kuma_point_total: Int?
    @Published var help_total: Int?
    
    init() {
        token = try? Realm().objects(CoopCardRealm.self).observe { _ in
            // 先頭のカード情報を使う（サブ垢は考えない）
            guard let realm = try? Realm().objects(CoopCardRealm.self).first else { return }
            self.job_num = realm.job_num.value
            self.ikura_total = realm.ikura_total.value
            self.golden_ikura_total = realm.golden_ikura_total.value
            self.kuma_point = realm.kuma_point.value
            self.kuma_point_total = realm.kuma_point_total.value
            self.help_total = realm.help_total.value
        }
    }
}

class UserInfoCore: ObservableObject {
    private var token: NotificationToken?
    
    // ユーザ情報の情報
    @Published var nsaid: String?
    @Published var nickname: String?
    // URLImageの仕様上, URL文字列にnilが入っていると落ちるのでその対策
    // 可愛いからこれでもいいよねっていう感じ
    @Published var imageUri: String?// = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var api_token: String?
    @Published var is_unlock: Bool = false
    @Published var is_develop: Bool = false
    @Published var is_imported: Bool = false

    init() {
        token = try? Realm().objects(UserInfoRealm.self).observe { _ in
            // 先頭のユーザ情報を使う（サブ垢は考えない）
            guard let realm = try? Realm().objects(UserInfoRealm.self).first else { return }
            self.nsaid = realm.nsaid
            self.nickname = realm.name
            self.imageUri = realm.image ?? "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
            self.iksm_session = realm.iksm_session
            self.session_token = realm.session_token
            self.api_token = realm.api_token
            self.is_unlock = realm.is_unlock
            self.is_develop = realm.is_develop
            self.is_imported = realm.is_imported
        }
    }
    
    func updateUnlock(_ is_unlock: Bool) {
        guard let realm = try? Realm() else { return }
        let user = realm.objects(UserInfoRealm.self)
        
        try? realm.write {
            user.setValue(is_unlock, forKey: "is_unlock")
        }
    }
}


//Template
//class UserCardCore: ObservableObject {
//    private var token: NotificationToken?
//
//    init() {
//        token = try? Realm().objects(CoopResultsRealm.self).observe { _ in
//
//        }
//    }
//}

