//
//  UserInfoCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class UserInfoCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var account: RealmSwift.Results<UserInfoRealm> = try! Realm().objects(UserInfoRealm.self)
    @Published var nsaid: String?
    @Published var nickname: String = "Salmonia2"
    @Published var imageUri: String = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var api_token: String?
    @Published var isActiveArray: [Bool] = []
    
    init() {
        token = try? Realm().objects(UserInfoRealm.self).observe { _ in
            guard let users = try? Realm().objects(UserInfoRealm.self) else { return }
            self.account = users
            guard let realm = users.first else { return }
            self.nsaid = realm.nsaid
            self.nickname = realm.name
            self.imageUri = realm.image
            self.iksm_session = realm.iksm_session
            self.session_token = realm.session_token
            self.isActiveArray = users.map({ $0.isActive })
        }
    }
}
