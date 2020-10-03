//
//  CoopShiftCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class CoopShiftCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var data: [CoopShiftRealm] = []

    init() {
        // 変更があるたびに再読込するだけ
        token = try? Realm().objects(CoopShiftRealm.self) .observe { [self] _ in
            guard let realm = try? Realm() else { return }
            let current_time: Int = Int(Date().timeIntervalSince1970) // 現在時刻を取得
            guard let end_time: Int = realm.objects(CoopShiftRealm.self).filter("end_time<=%@", current_time).sorted(byKeyPath: "start_time", ascending: true).last?.start_time else { return }
            data = Array(realm.objects(CoopShiftRealm.self).filter("start_time>=%@", end_time).sorted(byKeyPath: "start_time", ascending: true).prefix(3))
        }
    }
}
