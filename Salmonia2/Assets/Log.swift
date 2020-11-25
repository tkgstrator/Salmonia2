//
//  Log.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-20.
//

import Foundation

struct Log {
    var errorCode: String? = nil
    var errorDescription: String? = nil
    var status: String? = nil
//    var bias: Double = 2
    var isLock: Bool = true
    var isValid: Bool = true
    var progress: (id: Int?, min: Int?, max: Int?) = (nil, nil, nil)
}
