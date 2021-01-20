//
//  WaveType.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-01.
//

import Foundation

@dynamicMemberLookup
public enum SpecialType: CaseIterable {
    case inkjet, stingray, splashdown, bombpitcher
}

public enum SpecialTypeName: String, CaseIterable {
    case bombpitcher = "Bomb Pitcher"
    case stingray = "Sting Ray"
    case inkjet = "Inkjet"
    case splashdown = "Splashdown"
}

public enum SpecialTypeURL: String, CaseIterable {
    case bombpitcher = "18990f646c551ee77c5b283ec814e371f692a553.png"
    case stingray = "7af300fdd872feb27b3d8e68a969457fac8b3bb7.png"
    case inkjet = "9871c82952ed0141be0310ace1942c9f5f66d655.png"
    case splashdown = "324d41e9582d84101152849bc8c96d6595c9b0ff.png"
}

public enum SpecialTypeID: Int, CaseIterable {
    case bombpitcher = 2
    case stingray = 7
    case inkjet = 8
    case splashdown = 9
}

extension SpecialTypeID {
    var special_id: Int { rawValue }
}

extension SpecialTypeURL {
    var special_url: String { rawValue }
}

public extension SpecialType {
    init?(special_id: Int) {
        self.init(SpecialTypeID(rawValue: special_id))
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<SpecialTypeID, V>) -> V? {
        self[keyPath]
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<SpecialTypeURL, V>) -> V? {
        self[keyPath]
    }
    
    var image_url: URL {
        return URL(string: "https://app.splatoon2.nintendo.net/images/special/\(self.special_url!)")!
    }
}

private extension SpecialType {
    init?<T>(_ object: T?) where T: CaseIterable, T.AllCases.Index == AllCases.Index, T: Equatable {
        switch object {
        case let object? where object.offset < Self.allCases.endIndex:
            self = Self.allCases[object.offset]
        case _:
            return nil
        }
    }
    
    subscript<T, V>(_ keyPath: KeyPath<T, V>) -> V? where T: CaseIterable, T.AllCases.Index == AllCases.Index {
        (offset < T.allCases.endIndex) ? T.allCases[offset][keyPath: keyPath] : nil
    }
}
