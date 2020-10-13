//
//  WaveResultCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-09.
//

import Foundation
import RealmSwift

class WaveResultCore: ObservableObject {
    private var token: NotificationToken?
//    private var realm = try! Realm()
//    private var core = try! Realm().objects(WaveDetailRealm.self)
    
    @Published var waves = try! Realm().objects(WaveDetailRealm.self).sorted(byKeyPath: "golden_ikura_num", ascending: false)
    
    // フィルタリングとソーティングを解除
    func reset() {
        waves = realm.objects(WaveDetailRealm.self)
    }
    
    // イベントと潮位でフィルタリング
    func update(_ event: [Int], _ water: [Int], _ stage: [Int]) {
        let event_type: [String] = event.map({ (EventType.init(event_id: $0)?.event_name)! })
        let water_level: [String] = water.map({ (WaveType.init(water_level: $0)?.water_name)! })
        
        // イベントと潮位でフィルタリング
        waves = realm.objects(WaveDetailRealm.self).filter("event_type IN %@ and water_level IN %@ and ANY result.stage_id IN %@", event_type, water_level, stage).sorted(byKeyPath: "golden_ikura_num", ascending: false)
        // ステージでフィルタリング
    }
    
    init() {
        token = realm.objects(WaveDetailRealm.self).observe { [self] _ in
            waves = realm.objects(WaveDetailRealm.self).sorted(byKeyPath: "golden_ikura_num", ascending: false)
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
