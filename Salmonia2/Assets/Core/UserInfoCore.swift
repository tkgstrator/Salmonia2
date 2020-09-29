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
    
    @Published var account = RealmSwift.List<UserInfoRealm>()
    @Published var nsaid: String?
    @Published var nickname: String = "Salmonia2"
    @Published var imageUri: String = "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var api_token: String?

    init() {
        token = try? Realm().objects(UserInfoRealm.self).observe { [self] _ in
            guard let user = try? Realm().objects(SalmoniaUserRealm.self).first else { return }
            account = user.account
            guard let _account = user.account.first else { return }
            nsaid = _account.nsaid
            nickname = _account.name
            imageUri = _account.image
            iksm_session = _account.iksm_session
            session_token = _account.session_token
        }
        
        token = try? Realm().objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let user = try? Realm().objects(SalmoniaUserRealm.self).first else { return }
            account = user.account
            guard let _account = user.account.first else { return }
            nsaid = _account.nsaid
            nickname = _account.name
            imageUri = _account.image
            iksm_session = _account.iksm_session
            session_token = _account.session_token
        }

    }
}
