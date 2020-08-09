//
//  Extension.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String {
    // 正規表現マッチングを実現する
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
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


extension Double {
    // Swiftは桁丸めに対応していなので丸めるやつ
    func round(digit: Int) -> Double {
        return floor((pow(10.0, digit) as NSDecimalNumber).doubleValue * self) / (pow(10.0, digit) as NSDecimalNumber).doubleValue
    }
}

extension Optional {
    var value: String {
        switch self {
        case is Int:
            return String(self as! Int)
        case is Double:
            return String(self as! Double)
        case is String:
            return self as! String
        default:
            return "-"
        }
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension JSON {
    var intObject: [Int] {
        let str: String = self.stringValue.replacingOccurrences(of: " ", with: "")
        let substr: String = String(str[str.index(str.startIndex, offsetBy: 1) ..< str.index(str.endIndex, offsetBy: -1)])
        let array: [String] = substr.components(separatedBy: ",")
        let arrayInt: [Int] = array.map({ Int($0)! })
        return arrayInt
    }
}
// 一応実装できた
//extension Results where Iterator.Element == CoopResultsRealm {
//    func all(_ stage_id: Int) -> [CoopResultsRealm] {
//        return Array(self.filter({ $0.stage_id == stage_id && $0.wave.filter({ $0.ikura_num == 0}).count == 0 }))
//    }
//}
