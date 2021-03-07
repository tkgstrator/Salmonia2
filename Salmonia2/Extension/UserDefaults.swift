//
//  UserDefaults.swift
//  Salmonia2
//
//  Created by Devonly on 2021/03/07.
//

import Foundation

// データの読み書きを簡単に行うためのプロパティラッパー
@propertyWrapper
struct UserDefault<T> {
    let forKey: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: forKey) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: forKey)
        }
    }
}

// 変更を検知するための仕組みだけど、全部用意すべきなのかは謎
extension UserDefaults {
    @objc dynamic var futureRotation: Bool {
        return bool(forKey: "futureRotation")
    }

    @objc dynamic var rareWeapon: Bool {
        return bool(forKey: "rareWeapon")
    }

    @objc dynamic var apiToken: String {
        return string(forKey: "apiToken") ?? ""
    }
}
