//
//  RankType.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-03.
//

import Foundation

struct RankType {
    private let srpower: Double?
    
    init(value: Double?) {
        srpower = value
    }
}

extension RankType {
    var rank: String {
        guard let value = self.srpower else { return "-" }
        switch value {
        case (2600 ... 9999):
            return "X"
        case (2550 ..< 2600):
            return "S+9"
        case (2500 ..< 2550):
            return "S+8"
        case (2450 ..< 2500):
            return "S+7"
        case (2400 ..< 2450):
            return "S+6"
        case (2350 ..< 2400):
            return "S+5"
        case (2300 ..< 2350):
            return "S+4"
        case (2250 ..< 2300):
            return "S+3"
        case (2200 ..< 2250):
            return "S+2"
        case (2150 ..< 2200):
            return "S+1"
        case (2000 ..< 2150):
            return "S"
        case (1950 ..< 2000):
            return "A+"
        case (1900 ..< 1950):
            return "A"
        case (1800 ..< 1900):
            return "A-"
        case (1700 ..< 1800):
            return "B+"
        case (1600 ..< 1700):
            return "B"
        case (1500 ..< 1600):
            return "B-"
        case (1400 ..< 1500):
            return "C+"
        case (1300 ..< 1400):
            return "C"
        case (1000 ..< 1300):
            return "C-"
        default:
            return "-"
        }
    }
}
