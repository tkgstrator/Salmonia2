//
//  Extension.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import RealmSwift
import SwiftUI

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
    
    // 多言語対応
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Array {
    // 配列を指定した区切りにする
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension UserInfoRealm {
    func update(_ value: [String: Any]) throws -> Void {
        guard let realm = try? Realm() else { return }
        
        try realm.write {
            realm.create(UserInfoRealm.self, value: value, update: .modified)
        }
    }
}

extension UIColor {
    public convenience init(_ hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if ((cString.count) == 8) {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat((rgbValue & 0x0000FF)) / 255.0
            a = CGFloat((rgbValue & 0xFF000000)  >> 24) / 255.0
            
        } else if ((cString.count) == 6){
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat((rgbValue & 0x0000FF)) / 255.0
            a = CGFloat(1.0)
        }
        
        
        self.init(  red: r,
                    green: g,
                    blue: b,
                    alpha: a
        )
    }
}

