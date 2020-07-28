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
