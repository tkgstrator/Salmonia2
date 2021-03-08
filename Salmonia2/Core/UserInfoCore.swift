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
    private var usrToken: NSKeyValueObservation?

    
    @Published var active: [UserInfoRealm] = Array(realm.objects(UserInfoRealm.self).filter("isActive=%@", true))
    @Published var inactive: [UserInfoRealm] = Array(realm.objects(UserInfoRealm.self).filter("isActive=%@", false))
    @Published var nsaid: String?
    @Published var nickname: String = ""
    @Published var imageUri: String = "https://raw.githubusercontent.com/tkgstrator/Salmonia2/master/Salmonia2/Assets.xcassets/Default.imageset/default-1.png"
    @Published var iksm_session: String?
    @Published var session_token: String?
    @Published var version: String?
    @Published var api_token: String?
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    
    init() {
        token = realm.objects(UserInfoRealm.self).observe { [self] _ in
            print("USERINFO CHANGED")
            active = Array(realm.objects(UserInfoRealm.self).filter("isActive=%@", true))
            inactive = Array(realm.objects(UserInfoRealm.self).filter("isActive=%@", false))
            
            // アクティブなアカウントで一番先頭のものを取得
            guard let user = realm.objects(UserInfoRealm.self).filter("isActive=%@", true).first else { return }
            // TOP画面に表示するやつ
            nsaid = user.nsaid
            nickname = user.name
            imageUri = user.image
            job_num = user.job_num
            ikura_total = user.ikura_total
            golden_ikura_total = user.golden_ikura_total
            // データ取得に使うやつ
            iksm_session = user.iksm_session
            session_token = user.session_token
            
            // ここを上手くしたいのだが
            print("USERINFOREALM CHANGE",api_token, version)

        }
        
        // TODO: ちゃんと動作するかチェックすること
        // UserDefaultsが更新されたときに呼び出されるハズ
        usrToken = UserDefaults.standard.observe(\.apiToken, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            self!.api_token = UserDefaults.standard.string(forKey: "apiToken")
            self!.version = UserDefaults.standard.string(forKey: "version")
            print("USERDEFAULTS CHANGE", self!.api_token, self!.version)
        })
    }
    deinit {
        token?.invalidate()
    }
}
