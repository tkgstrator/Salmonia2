//
//  UserDefaultsCore.swift
//  Salmonia2
//
//  Created by Devonly on 2021/02/21.
//

import Foundation

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

class UnlockCore: ObservableObject {
    @UserDefault(forKey: "futureRotation", defaultValue: false)
    var futureRotation: Bool
    @UserDefault(forKey: "rareWeapon", defaultValue: false)
    var rareWeapon: Bool
    @UserDefault(forKey: "forceReload", defaultValue: false)
    var forceReload: Bool
    @UserDefault(forKey: "disableAds", defaultValue: false)
    var disableAds: Bool
    @UserDefault(forKey: "legacyStyle", defaultValue: false)
    var legacyStyle: Bool
    @UserDefault(forKey: "displayName", defaultValue: false)
    var displayName: Bool
    
}

class RainbowCore: ObservableObject {
    @UserDefault(forKey: "title", defaultValue: false)
    var title: Bool
    @UserDefault(forKey: "result", defaultValue: false)
    var result: Bool
    @UserDefault(forKey: "resultOverview", defaultValue: false)
    var resultOverview: Bool
    @UserDefault(forKey: "resultName", defaultValue: false)
    var resultName: Bool
    @UserDefault(forKey: "resultQuota", defaultValue: false)
    var resultQuota: Bool
    @UserDefault(forKey: "resultPlayer", defaultValue: false)
    var resultPlayer: Bool
    @UserDefault(forKey: "shiftParam", defaultValue: false)
    var shiftParam: Bool
    @UserDefault(forKey: "shiftValue", defaultValue: false)
    var shiftValue: Bool
}
