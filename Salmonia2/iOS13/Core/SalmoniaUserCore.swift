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
    @Published var isPurchase: Bool = false
    @Published var isDevelop: Bool = false
    @Published var isUnlock: Bool = false
    @Published var account = RealmSwift.List<UserInfoRealm>()
    @Published var favuser = RealmSwift.List<CrewInfoRealm>()
    @Published var isActiveArray: [Bool] = []

    init() {
        token = try? Realm().objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let user = try? Realm().objects(SalmoniaUserRealm.self).first else { return }
            api_token = user.api_token
            isImported = user.isImported
            isUnlock = user.isUnlock
            isDevelop = user.isDevelop
            isPurchase = user.isPurchase
            account = user.account
            favuser = user.favuser
            isActiveArray = user.account.map({ $0.isActive })
        }
        
        token = try? Realm().objects(UserInfoRealm.self).observe { [self] _ in
            guard let user = try? Realm().objects(SalmoniaUserRealm.self).first else { return }
            api_token = user.api_token
            isImported = user.isImported
            isUnlock = user.isUnlock
            isDevelop = user.isDevelop
            isPurchase = user.isPurchase
            account = user.account
            favuser = user.favuser
            isActiveArray = user.account.map({ $0.isActive })
//            guard let realm = try? Realm() else { return }
//            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
//            let favusers = realm.objects(CrewInfoRealm.self).filter("isFav=%@", true)
//            realm.beginWrite()
//             ユーザを全削除（追加は楽だが、削除が意外と難しい）
//            user.favuser.removeAll()
//            for favuser in favusers {
//                user.favuser.append(favuser)
//            }
//            try? realm.commitWrite()
//            favuser = user.favuser
        }

    }
}
