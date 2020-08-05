//
//  Extension.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import RealmSwift

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

extension Realm {
    func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)
                    
                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}
