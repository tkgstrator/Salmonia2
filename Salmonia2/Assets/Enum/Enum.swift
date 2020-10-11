//
//  Enum.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI

enum APIError: Error {
    case Response(String, String)
}

extension Color {
    static let cGreen = Color("cGreen")
    static let cRed = Color("cRed")
    static let cDark = Color("cDark")
    static let cDarkRed = Color("cDarkRed")
    static let cOrange = Color("cOrange")
    static let cGray = Color("cGray")
    static let cLightGray = Color("cLightGray")
}
