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

class SalmoniaCore: ObservableObject {
    @ObservedObject var user = UserInfoCore() // 自分の情報しか保持しない
    @ObservedObject var card = UserCardCore()
    @ObservedObject var data = UserResultsCore()
}

class UserResultsCore: ObservableObject {
    private var token: NotificationToken?
    
    // 自分のリザルトをすべて保存している
    @Published var results: Results<CoopResultsRealm>?
    
    // ちょいダサい？
    init() {
        token = try? Realm().objects(CoopResultsRealm.self).observe { _ in
            guard let realm = try? Realm().objects(CoopResultsRealm.self) else { return }
            self.results = realm
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
            self.job_num = realm.job_num
            self.ikura_total = realm.ikura_total
            self.golden_ikura_total = realm.golden_ikura_total
            self.kuma_point = realm.kuma_point
            self.kuma_point_total = realm.kuma_point_total
            self.help_total = realm.help_total
        }
    }
}

class UserInfoCore: ObservableObject {
    private var token: NotificationToken?

    // ユーザ情報の情報
    @Published var nsaid: String?
    @Published var nickname: String?
    @Published var imageUri: String?
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var api_token: String?

    init() {
        token = try? Realm().objects(UserInfoRealm.self).observe { _ in
            // 先頭のユーザ情報を使う（サブ垢は考えない）
            guard let realm = try? Realm().objects(UserInfoRealm.self).first else { return }
            self.nsaid = realm.nsaid
            self.nickname = realm.name
            self.imageUri = realm.image
            self.iksm_session = realm.iksm_session
            self.session_token = realm.session_token
            self.api_token = realm.api_token
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

