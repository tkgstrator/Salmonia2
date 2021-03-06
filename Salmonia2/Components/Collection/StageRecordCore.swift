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
    @Published var salmon_id: [[CoopResultsRealm?]] = [Array<CoopResultsRealm?>(repeating: nil, count: 7), Array<CoopResultsRealm?>(repeating: nil, count: 7), Array<CoopResultsRealm?>(repeating: nil, count: 7)]
    @Published var team_golden_eggs: [Int?] = [nil, nil]
    
    init(_ id: Int) {
        token = realm.objects(CoopResultsRealm.self).observe { [self] _ in
            stage_id = id
            let results = realm.objects(CoopResultsRealm.self).filter("stage_id=%@", id).sorted(byKeyPath: "play_time")
            let waves = realm.objects(WaveDetailRealm.self).filter("ANY result.stage_id=%@", id)
            
            job_num = results.count == 0 ? nil : results.count
            // 各記録を計算する
            clear_ratio = (job_num != nil) ? (Double(results.filter("is_clear=%@", true).count * 100) / Double(job_num!)).round(digit: 4) : nil
            grade_point = results.max(ofProperty: "grade_point") // 最高評価

            for tide in Range(0 ... 2) {
                for event in Range(0 ... 6) {
                    guard let event_type = EventType.init(event_id: event)?.event_name else { return }
                    guard let water_level = WaveType.init(water_level: tide)?.water_name else { return }
                    let golden_ikura_num: Int? = waves.filter("event_type=%@ and water_level=%@", event_type, water_level).max(ofProperty: "golden_ikura_num")
                    golden_eggs[tide][event] = golden_ikura_num
                    if golden_ikura_num != nil {
                        salmon_id[tide][event] = waves.filter("event_type=%@ and water_level=%@ and golden_ikura_num=%@", event_type, water_level, golden_ikura_num).first?.result.first
                    }
                }
            }
//            print(salmon_id)
            team_golden_eggs[0] = results.max(ofProperty: "golden_eggs")
            team_golden_eggs[1] = results.filter("SUBQUERY(wave, $wave, $wave.event_type=%@).@count==3", "-").max(ofProperty: "golden_eggs")
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

