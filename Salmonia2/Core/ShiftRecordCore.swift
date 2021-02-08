//
//  ShiftRecordCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-20.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import Alamofire
import SwiftyJSON

class ShiftRecordCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var start_time: Int = 0
    @Published var total: [Int?] = [nil, nil]
    @Published var no_night_total: [Int?] = [nil, nil]
    @Published var global: [[Int?]] = [Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7)]
    @Published var personal: [[Int?]] = [Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7)]
    @Published var salmon_id: [[CoopResultsRealm?]] = [Array<CoopResultsRealm?>(repeating: nil, count: 7), Array<CoopResultsRealm?>(repeating: nil, count: 7), Array<CoopResultsRealm?>(repeating: nil, count: 7)]
    @Published var event_occur: [[Int?]] = [Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7), Array<Int?>(repeating: nil, count: 7)]
    
    // 統計を計算する
    @Published var variance: [[Double?]] = [Array<Double?>(repeating: nil, count: 7), Array<Double?>(repeating: nil, count: 7), Array<Double?>(repeating: nil, count: 7)]
    @Published var average: [[Double?]] = [Array<Double?>(repeating: nil, count: 7), Array<Double?>(repeating: nil, count: 7), Array<Double?>(repeating: nil, count: 7)]

    init(_ start_time: Int) {
        token = realm.objects(WaveRecordsRealm.self).observe { [self] _ in
            self.start_time = start_time

            let global_records = realm.objects(WaveRecordsRealm.self).filter("start_time=%@", start_time)
            let personal_records = realm.objects(WaveDetailRealm.self).filter("ANY result.start_time=%@", start_time)

            // 潮位・イベントごとの記録
            for tide in Range(0 ... 2) {
                for event in Range(0 ... 6) {
                    let global_eggs: Int? = global_records.filter("event_type=%@ and water_level=%@", event, tide).max(ofProperty: "golden_ikura_num")
                    guard let event_type = EventType.init(event_id: event)?.event_name else { return }
                    guard let water_level = WaveType.init(water_level: tide)?.water_name else { return }
                    let personal_eggs: Int? = personal_records.filter("event_type=%@ and water_level=%@", event_type, water_level).max(ofProperty: "golden_ikura_num")
                    global[tide][event] = global_eggs
                    personal[tide][event] = personal_eggs
                    
                    // 統計とかの計算
                    let waves: RealmSwift.Results<WaveDetailRealm> = personal_records.filter("event_type=%@ and water_level=%@", event_type, water_level)
                    average[tide][event] = waves.average(ofProperty: "golden_ikura_num")
                    if average[tide][event] != nil {
                        variance[tide][event] = sqrt((Double(waves.map({ pow(Double($0.golden_ikura_num), 2) }).reduce(0.0, +) / Double(waves.count)) - pow(average[tide][event]!, 2) / Double(waves.count)))
                    }
                    if (!(tide == 0 && event <= 3 && event >= 1) && !(tide != 0 && event == 6)) {
                        event_occur[tide][event] = personal_records.filter("event_type=%@ and water_level=%@", event_type, water_level).count
                    }
                    print(average[tide][event], variance[tide][event])
                }
            }
            
            // 夜ありと昼のみ
            total[0] = global_records.filter("event_type=%@", -1).max(ofProperty: "golden_ikura_num")
            no_night_total[0] = global_records.filter("event_type=%@", -2).max(ofProperty: "golden_ikura_num")
            
            let results = realm.objects(CoopResultsRealm.self).filter("start_time=%@", start_time)
            total[1] = results.max(ofProperty: "golden_eggs")
            no_night_total[1] = results.filter("SUBQUERY(wave, $wave, $wave.event_type=%@).@count==3", "-").max(ofProperty: "golden_eggs")
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

extension ShiftRecordCore {
    func count(_ event_type: Int) -> Int {
        guard let event = EventType.init(event_id: event_type)?.event_name else { return 0 }
        return realm.objects(WaveDetailRealm.self).filter("ANY result.start_time=%@ and event_type=%@", self.start_time, event).count
    }
    
    var count: Int {
        return realm.objects(WaveDetailRealm.self).filter("ANY result.start_time=%@", self.start_time).count
    }
}
