//
//  Enum.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI


enum APPError: Error {
    case unknown
    case empty
    case expired
    case realm
    case user
    case coop
    case active
    case apitoken
    case iksm
    case session
    case unavailable
    case value
}

extension APPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "ERROR_UNKNOWN"
        case .empty:
            return "ERROR_EMPTY"
        case .expired:
            return "ERROR_EXPIRED"
        case .realm:
            return "ERROR_REALM"
        case .user:
            return "ERROR_USER"
        case .coop:
            return "ERROR_COOP"
        case .active:
            return "ERROR_ACTIVE"
        case .apitoken:
            return "ERROR_TOKEN"
        case .iksm:
            return "ERROR_SESSIONKEY"
        case .session:
            return "ERROR_SESSIONTOKEN"
        case .unavailable:
            return "ERROR_UNAVAILABLE"
        case .value:
            return "ERROR_VALUE"
        }
    }
    
    var localizedDescription: String? {
        switch self {
        case .unknown:
            return "DESC_UNKNOWN"
        case .empty:
            return "DESC_EMPTY"
        case .expired:
            return "DESC_EXPIRED"
        case .realm:
            return "DESC_REALM"
        case .user:
            return "DESC_USER"
        case .coop:
            return "DESC_COOP"
        case .active:
            return "DESC_ACTIVE"
        case .apitoken:
            return "DESC_TOKEN"
        case .iksm:
            return "DESC_SESSIONKEY"
        case .session:
            return "DESC_SESSIONTOKEN"
        case .unavailable:
            return "DESC_UNAVAILABLE"
        case .value:
            return "DESC_VALUE"
        }
    }
}


extension APPError: CustomNSError {
    var errorCode: Int {
        switch self {
        case .unknown:
            return 9999
        case .empty:
            return 9402
        case .expired:
            return 9403
        case .realm:
            return 9000
        case .user:
            return 9999
        case .coop:
            return 9001
        case .active:
            return 9002
        case .apitoken:
            return 1003
        case .iksm:
            return 1000
        case .session:
            return 1001
        case .unavailable:
            return 9503
        case .value:
            return 9504
        }
    }
}

extension Color {
    static let cGreen = Color("cGreen")
    static let cRed = Color("cRed")
    static let cDark = Color("cDark")
    static let cDarkRed = Color("cDarkRed")
    static let cOrange = Color("cOrange")
    static let cGray = Color("cGray")
    static let cDarkGray = Color("cDarkGray")
    static let cLightGray = Color("cLightGray")
    static let cBlue = Color("cBlue")
}

enum SKError: Error {
    case unknown
    case invalid
    case expired
}

extension SKError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "PAYMENT_UNKNOWN"
        case .invalid:
            return "PAYMENT_INVALID"
        case .expired:
            return "PAIMENT_EXPIRED"
        }
    }
}

extension SKError: CustomNSError {
    var errorCode: Int {
        switch self {
        case .unknown:
            return 9999
        case .invalid:
            return 1000
        case .expired:
            return 2000
        }
    }
}
