//
//  View.swift
//  Salmonia2
//
//  Created by Devonly on 2021/03/09.
//

import Foundation
import SwiftUI

extension View {
    func rainbow(_ flag: Bool) -> some View {
        switch flag {
        case true:
            return AnyView(self.modifier(Rainbow()))
        case false:
            return AnyView(self)
        }
    }
    
    func rainbowAnimation(_ flag: Bool) -> some View {
        switch flag {
        case true:
            return AnyView(self.modifier(RainbowAnimation()))
        case false:
            return AnyView(self)
        }
    }
}
