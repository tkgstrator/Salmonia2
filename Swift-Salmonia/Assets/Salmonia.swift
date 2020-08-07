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

// 評価値からサーモンランのウデマエIDを返す（だいたいたつじんだろうとおもうけれど...
func GradeID(_ point: Int?) -> Int? {
    guard let point = point else { return nil }
    return min(5, 1 + (point / 100))
}

// 評価レートを計算する関数
func Grade(_ point: Int?) -> Int? {
    guard let point = point else { return nil }
    return point - min(4, (point / 100)) * 100
}

// 回線落ちは計算困難なので無視する
func GradeDelta(_ wave: Int) -> Int {
    if wave == 3 { return 20 }
    return (wave - 2) * 10
}

