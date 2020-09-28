//
//  UserCardCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class UserCardCore: ObservableObject {
    private var token: NotificationToken?
    
    // カード情報
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    @Published var kuma_point: Int = 0
    @Published var kuma_point_total: Int = 0
    @Published var help_total: Int = 0
    
    init() {
        token = try? Realm().objects(CoopCardRealm.self).observe { _ in
            guard let users = try? Realm().objects(UserInfoRealm.self) else { return }
            guard let nsaid = users.first?.nsaid else { return }
//            guard let nsaid = users.filter("isActive=%@", true).first?.nsaid else { return }
            guard let realm = try? Realm().objects(CoopCardRealm.self).filter("nsaid=%@", nsaid).first else { return }
            self.job_num = realm.job_num.value ?? 0
            self.ikura_total = realm.ikura_total.value ?? 0
            self.golden_ikura_total = realm.golden_ikura_total.value ?? 0
            self.kuma_point = realm.kuma_point.value ?? 0
            self.kuma_point_total = realm.kuma_point_total.value ?? 0
            self.help_total = realm.help_total.value ?? 0
        }
        
        token = try? Realm().objects(UserInfoRealm.self).observe { _ in
            guard let users = try? Realm().objects(UserInfoRealm.self) else { return }
            guard let nsaid = users.first?.nsaid else { return }
//            guard let nsaid = users.filter("isActive=%@", true).first?.nsaid else { return }
            guard let realm = try? Realm().objects(CoopCardRealm.self).filter("nsaid=%@", nsaid).first else { return }
            self.job_num = realm.job_num.value ?? 0
            self.ikura_total = realm.ikura_total.value ?? 0
            self.golden_ikura_total = realm.golden_ikura_total.value ?? 0
            self.kuma_point = realm.kuma_point.value ?? 0
            self.kuma_point_total = realm.kuma_point_total.value ?? 0
            self.help_total = realm.help_total.value ?? 0
        }

    }
}
