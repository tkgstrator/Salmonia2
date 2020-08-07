//
//  Salmonia.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import SwiftyJSON

// いろいろな独自の変換関数を保持しているところ


// Salmon StatsのDate形式をTimestamp変換
func Unixtime(time: String) -> Int {
    let f = DateFormatter()
    f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
    f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return Int((f.date(from: time) ?? Date()).timeIntervalSince1970)
}

// Timestamp型を日付に変換
func Unixtime(interval: Int) -> String {
    let f = DateFormatter()
    f.dateFormat = "MM/dd HH:mm"
    return f.string(from: Date(timeIntervalSince1970: TimeInterval(interval)))
}

// 以下、Salmon Statsからのデータを変換するための関数
// Salmon Statsの失敗原因IDをメッセージに変換
func Reason(id: Int) -> String? {
    return reasons.filter({ $0.id == id }).first?.key
}

// Salmon Statsの失敗したWAVE情報をクリアWAVEに変換
func Failure(waves: Int) -> Int? {
    return waves == 3 ? nil : waves + 1
}

// 評価値からサーモンランのウデマエIDを返す（だいたいたつじんだろうとおもうけれど...
func GradeID(point: Int?) -> Int? {
    guard let point = point else { return nil }
    return min(5, 1 + (point / 100))
}

// 評価レートを計算する関数
func Grade(point: Int?) -> Int? {
    guard let point = point else { return nil }
    return point - min(4, (point / 100)) * 100
}

// 回線落ちは計算困難なので無視する
func GradeDelta(wave: Int) -> Int {
    if wave == 3 { return 20 }
    return (wave - 2) * 10
}

// ここまで



// 潮位を文字列で返す関数
func Tide(id: Int) -> String {
    return tides.filter({ $0.id == id }).first!.key
}

// イベント名を文字列で返す関数
func Event(id: Int) -> String {
    return events.filter({ $0.ss == id }).first!.key
}


private let reasons: [(id: Int, key: String?)] = [
    (0, nil),
    (1, "wipe_out"),
    (2, "time_limit")
]


private let events: [(s2: Int, ss: Int, key: String)] = [
    (0, 0, "-"),
    (1, 6, "rush"),
    (2, 3, "goldie-seeking"),
    (3, 4, "griller"),
    (4, 5, "the-mothership"),
    (5, 2, "fog"),
    (6, 1, "cohock-charge"),
]

private let tides: [(id: Int, key: String)] = [
    (1, "low"),
    (2, "normal"),
    (3, "high")
]
