//
//  SalmoniaUserCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class SalmoniaUserCore: ObservableObject {
    private var token: NotificationToken?

    @Published var api_token: String?
    @Published var isImported: Bool = false
    @Published var isLogined: Bool = false
    @Published var isUnlock: [Bool] = [false, false, false, false, false, false]
    @Published var isPurchase: Bool = false
    @Published var account = RealmSwift.List<UserInfoRealm>()
    @Published var favuser = RealmSwift.List<CrewInfoRealm>()
    @Published var isActiveArray: [Bool] = []
    @Published var isVersion: String = "1.10.0"

    init() {
        // API TOKENが変更されたときにチェックする
        token = realm.objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
            isPurchase = user.isPurchase
            api_token = user.api_token
            isImported = user.isImported
            isLogined = user.api_token != nil
            isUnlock = Array(user.isUnlock.map({ $0 }))
            account = user.account
            favuser = user.favuser
            isActiveArray = user.account.map({ $0.isActive })
            isVersion = user.isVersion
        }
    }
    
    func updateUnlock(_ unlock: [Bool]) {
        guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
        try? realm.write() {
            user.setValue(unlock, forKey: "isUnlock")
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
