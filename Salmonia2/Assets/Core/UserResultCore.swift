//
//  UserResultCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class UserResultCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var results: RealmSwift.Results<CoopResultsRealm> = try! Realm().objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false)

    init() {
        // 変更があるたびに再読込するだけ
        token = try? Realm().objects(CoopResultsRealm.self) .observe { _ in
            guard let results = try? Realm().objects(CoopResultsRealm.self).sorted(byKeyPath: "play_time", ascending: false) else { return }
            self.results = results
        }
    }
}
