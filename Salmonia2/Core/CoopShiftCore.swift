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
    private var token: NotificationToken? // Realmを関しsる
    private var futureRotation: NSKeyValueObservation? // UserDefaultsを監視する
    private var rareWeapon: NSKeyValueObservation? // TOPページのクマブキ表示切り替え用
    
    private let current_time: Int = Int(Date().timeIntervalSince1970) // 現在時刻を取得
    
    @ObservedObject var unlock = UnlockCore()

    @Published var isUnlockWeapon: Bool = false
    @Published var isUnlockRotation: Bool = false
    @Published var data: [CoopShiftRealm] = []
    @Published var now: Results<CoopShiftRealm> = realm.objects(CoopShiftRealm.self).filter("start_time<=%@", Int(Date().timeIntervalSince1970))
    @Published var all: Results<CoopShiftRealm>  = realm.objects(CoopShiftRealm.self).sorted(byKeyPath: "start_time", ascending: false)

    init() {
        // これは固定なので毎回呼ばなくても大丈夫
        data = Array(realm.objects(CoopShiftRealm.self).filter("end_time>=%@", current_time).sorted(byKeyPath: "start_time", ascending: true).prefix(2))

        // シフトをどこまで表示するかどうか
        futureRotation = UserDefaults.standard.observe(\.futureRotation, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            if self!.unlock.futureRotation {
                self!.all = realm.objects(CoopShiftRealm.self).sorted(byKeyPath: "start_time", ascending: false)
            } else {
                self!.all = realm.objects(CoopShiftRealm.self).filter("start_time <=%@", self!.current_time).sorted(byKeyPath: "start_time", ascending: false)
            }
        })

        // TOPページのレアブキ更新用
        rareWeapon = UserDefaults.standard.observe(\.rareWeapon, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            self!.data = Array(realm.objects(CoopShiftRealm.self).filter("end_time>=%@", self!.current_time).sorted(byKeyPath: "start_time", ascending: true).prefix(2))
        })

    }
    
    func update(isEnable: [Bool], isPlayed: Bool, isTime: [Bool]) {
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

        // シフトをどこまで表示するかどうか
        if !unlock.futureRotation {
            all = realm.objects(CoopShiftRealm.self).filter("start_time IN %@ AND start_time<=%@", _start_time, current_time).sorted(byKeyPath: "start_time", ascending: false)
        } else {
            all = realm.objects(CoopShiftRealm.self).filter("start_time IN %@", _start_time).sorted(byKeyPath: "start_time", ascending: false)
        }
    }
    
    deinit {
        token?.invalidate()
        futureRotation?.invalidate()
    }
}

extension UserDefaults {
    @objc dynamic var futureRotation: Bool {
        return bool(forKey: "futureRotation")
    }

    @objc dynamic var rareWeapon: Bool {
        return bool(forKey: "rareWeapon")
    }
}
