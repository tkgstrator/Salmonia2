//
//  Extension.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-21.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation

extension String {
    //　文字列をローカライズする
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    // 日付を数値に変換する
    var unixtime: Int {
        let f = DateFormatter()
        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Int((f.date(from: self) ?? Date()).timeIntervalSince1970)
    }
    
    // それの別バージョン（これらは統合したいよね）
    var unix: Int {
        let f = DateFormatter()
        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return Int((f.date(from: self) ?? Date()).timeIntervalSince1970)
    }
    
    // 正規表現マッチング（session_token_codeを利用するときにのみ使う）
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    // 正規表現マッチング（session_token_codeを利用するときにのみ使う）
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}

extension Int {
    
    // Salmon Stats型のIDをSplatNet2型に変換する（ダサいからExtention以外で対応したい
    var reasonid: String? {
        switch self {
        case 0:
            return nil
        case 1:
            return "wipe_out"
        case 2:
            return "time_limit"
        default:
            return nil
        }
    }
    
    var waterid: String {
        switch self {
        case 0:
            return "low"
        case 1:
            return "normal"
        case 2:
            return "high"
        default:
            return "normal"
        }
        
    }
    
    var eventid: String {
        switch self {
        case 0:
            return "-"
        case 1:
            return "cohock-charge"
        case 2:
            return "fog"
        case 3:
            return "goldie-seeking"
        case 4:
            return "griller"
        case 5:
            return "the-mothership"
        case 6:
            return "rush"
        default:
            return "-"
        }
    }
    
    // 数値をURLに変換するところだけど、ダサいよね Weapon(Int?)でWeapon型が返るようにしたい
    var weapon: String {
        let base = "https://app.splatoon2.nintendo.net/images/weapon/"
        return base + (Enum().Weapon.filter({ $0.id == self}).first?.url ?? "")
    }
    
    // 同上
    var stage: String {
        let base = "https://app.splatoon2.nintendo.net/images/coop_stage/"
        return base + (Enum().Stage.filter({ $0.id == self}).first?.url ?? "")
    }
    
    // 数値をシフト表示に変換する（TimeZone付けるとバグっちゃう気がするからつけないほうが多分いい
    var date: String {
        let f = DateFormatter()
//        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
}

extension Double {
    // Swiftは桁丸めに対応していなので丸めるやつ
    func round(digit: Int) -> Double {
        return floor((pow(10.0, digit) as NSDecimalNumber).doubleValue * self) / (pow(10.0, digit) as NSDecimalNumber).doubleValue
    }
}

extension Optional {
    // Optional型を文字列に変換する
    var string: String {
        switch self {
        case is Int:
            return String(self as! Int)
        case is Double:
            return String(self as! Double)
        default:
            return "-"
        }
    }
}
