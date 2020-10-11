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
    @Published var all: Results<CoopShiftRealm>  = try! Realm().objects(CoopShiftRealm.self).sorted(byKeyPath: "start_time")

    init() {
        // 変更があるたびに再読込するだけ
        token = try? Realm().objects(CoopShiftRealm.self) .observe { [self] _ in
            guard let realm = try? Realm() else { return }
            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
            let current_time: Int = Int(Date().timeIntervalSince1970) // 現在時刻を取得
            guard let end_time: Int = realm.objects(CoopShiftRealm.self).filter("end_time<=%@", current_time).sorted(byKeyPath: "start_time", ascending: true).last?.start_time else { return }
            data = Array(realm.objects(CoopShiftRealm.self).filter("start_time>=%@", end_time).sorted(byKeyPath: "start_time", ascending: true).prefix(3))
            
            if !(user.isUnlock) {
                all = realm.objects(CoopShiftRealm.self).filter("start_time<=%@", current_time).sorted(byKeyPath: "start_time", ascending: true)
            }
        }
    }
    
    func update(isEnable: [Bool], isPlayed: Bool) {
        guard let realm = try? Realm() else { return }
        
        // 該当するシフトのstart_timeを持つ、Intなのでオブジェクト全てを持つよりは相当軽いはず
        var _start_time: [Int] = []
        let played: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.start_time })
        let phase = !isPlayed ? realm.objects(CoopShiftRealm.self) : realm.objects(CoopShiftRealm.self).filter("start_time IN %@", played)

        if isEnable[0] {
            _start_time.append(contentsOf: phase.filter({ $0.weapon_list.reduce(0, +) == -8 }).map({ $0.start_time })) // Grizzco Rotation
        }
        if isEnable[1] {
            _start_time.append(contentsOf: phase.filter({ $0.weapon_list.reduce(0, +) == -4 }).map({ $0.start_time })) // All Random Rotation
        }
        if isEnable[2] {
            _start_time.append(contentsOf: phase.filter({ $0.weapon_list.reduce(0, +) % 10 == 9 }).map({ $0.start_time })) // One Random Rotation
        }
        if isEnable[3] {
            _start_time.append(contentsOf: phase.filter({ $0.weapon_list.reduce(0, +) % 10 == 0 }).map({ $0.start_time })) // Normal Rotation
        }
        _start_time = _start_time.sorted() // ソートします
        print(_start_time)
        
        all = realm.objects(CoopShiftRealm.self).filter("start_time IN %@", _start_time)
    }
}
