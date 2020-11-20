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
    @Published var imageUri: String = "https://raw.githubusercontent.com/tkgstrator/Salmonia2/master/Salmonia2/Assets.xcassets/Default.imageset/default-1.png"
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var api_token: String?
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    
    init() {
        token = realm.objects(UserInfoRealm.self).observe { [self] _ in
            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
            account = user.account
            guard let _account = user.account.first else { return }
            nsaid = _account.nsaid
            nickname = _account.name
            imageUri = _account.image
            iksm_session = _account.iksm_session
            session_token = _account.session_token
            job_num = _account.job_num
            ikura_total = _account.ikura_total
            golden_ikura_total = _account.golden_ikura_total
        }
        
        token = realm.objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
            account = user.account
            guard let _account = user.account.first else { return }
            nsaid = _account.nsaid
            nickname = _account.name
            imageUri = _account.image
            iksm_session = _account.iksm_session
            session_token = _account.session_token
            job_num = _account.job_num
            ikura_total = _account.ikura_total
            golden_ikura_total = _account.golden_ikura_total
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
