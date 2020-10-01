//
//  StageRecordCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-01.
//

import Foundation
import RealmSwift

class StageRecordCore: ObservableObject {
    private var token: NotificationToken?
    @Published var stage_id: Int?
    @Published var job_num: Int?
    @Published var grade_point: Int?
    @Published var srpower: [Double?] = [nil, nil]
    @Published var clear_ratio: Double?
    @Published var golden_eggs: [[Int?]] = [Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7)]
    @Published var team_golden_eggs: [Int?] = [nil, nil]
    
    init(_ id: Int) {
        token = try? Realm().objects(CoopResultsRealm.self).observe { [self] _ in
            stage_id = id
            guard let realm = try? Realm() else { return }
            let results = realm.objects(CoopResultsRealm.self).filter("stage_id=%@", id).sorted(byKeyPath: "play_time")
            let waves = realm.objects(WaveDetailRealm.self).filter("ANY result.stage_id=%@", id)
            
            job_num = results.count
            // 各記録を計算する
            clear_ratio = (job_num != 0) ? (Double(results.filter("is_clear=%@", true).count * 100) / Double(job_num!)).round(digit: 4) : nil
            grade_point = results.max(ofProperty: "grade_point") // 最高評価
            srpower = SRPower(results)
            
            for tide in Range(0 ... 2) {
                for event in Range(0 ... 6) {
                    guard let event_type = EventType.init(event_id: event)?.event_name else { return }
                    guard let water_level = WaveType.init(water_level: tide)?.water_name else { return }
                    let golden_ikura_num: Int? = waves.filter("event_type=%@ and water_level=%@", event_type, water_level).max(ofProperty: "golden_ikura_num")
                    golden_eggs[tide][event] = golden_ikura_num
                }
            }
            team_golden_eggs[0] = results.max(ofProperty: "golden_eggs")
            team_golden_eggs[1] = results.filter("SUBQUERY(wave, $wave, $wave.event_type=%@).@count==3", "-").max(ofProperty: "golden_eggs")
        }
    }
}

