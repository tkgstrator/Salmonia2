//
//  Extension.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-21.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    var unixtime: Int {
        let f = DateFormatter()
        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Int((f.date(from: self) ?? Date()).timeIntervalSince1970)
    }
    
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

extension Int {
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
}

extension Optional {
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
