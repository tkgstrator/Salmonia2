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
    case expired
    case realm
    case user
    case coop
    case active
    case apitoken
    case iksm
    case session
    case noempty
    case unavailable
}

extension APPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown Error"
        case .expired:
            return "Iksm Session is Unauthorized/Expired"
        case .realm:
            return "Realm Database Broken"
        case .user:
            return "Login SplatNet2"
        case .coop:
            return "Realm Database Broken"
        case .active:
            return "No Active NSO Account"
        case .apitoken:
            return "Login Salmon Stats"
        case .iksm:
            return "No iksm session"
        case .session:
            return "No session token"
        case .noempty:
            return "Input Emtpy"
        case .unavailable:
            return "Server is Unavailable"
        }
    }
}

extension APPError: CustomNSError {
    var errorCode: Int {
        switch self {
        case .unknown:
            return 9999
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
        case .noempty:
            return 1002
        case .unavailable:
            return 9503
        }
    }
}

enum Notification {
    case login
    case update
    case laravel
    case unlock
    case lock
    case error
    case success
    case failure
}

extension Notification {
    var localizedDescription: String {
        switch self {
        case .login:
            return "Add new NSO account"
        case .update:
            return "Update NSO account"
        case .laravel:
            return "Login Salmon Stats"
        case .unlock:
            return "Unlock feature"
        case .lock:
            return "Lock feature"
        case .error:
            return "Unkonwn error"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
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
            return "Unknown Error"
        case .invalid:
            return "Invalid ProductId"
        case .expired:
            return "Subscription is Expired"
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
