//
//  Salmonia.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import SwiftyJSON

// Salmon StatsのDate形式をTimestamp変換
func Unixtime(time: String) -> Int {
    let f = DateFormatter()
    f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
    f.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return Int((f.date(from: time) ?? Date()).timeIntervalSince1970)
}

// Salmon StatsのDate形式をUTC時間整数に変換
func SSTime(time: String) -> Int {
    let timestamp: Int = Unixtime(time: time)
    let f = DateFormatter()
    f.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    f.dateFormat = "yyyyMMddHH"
    return Int(f.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp))))!
}

// Timestamp型を日付に変換
func Unixtime(interval: Int) -> String {
    let f = DateFormatter()
    f.dateFormat = "MM/dd HH:mm"
    return f.string(from: Date(timeIntervalSince1970: TimeInterval(interval)))
}

// 以下、Salmon Statsからのデータを変換するための関数
// Salmon Statsの失敗原因IDをメッセージに変換
