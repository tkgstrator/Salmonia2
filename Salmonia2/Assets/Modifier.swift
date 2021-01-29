//
//  Modifier.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import URLImage
import RealmSwift
import WebKit


extension Image {
    func Modifier(_ isEnabled: Bool = true) -> some View {
        self
            .resizable()
            .scaledToFit()
            .foregroundColor(isEnabled ? .white : .cGray)
            .frame(width: 25, height: 25)
    }
}

struct Splatfont: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        if NSLocale.preferredLanguages[0].prefix(2) == "zh" {
            return
                content
                .font(.custom("FZYHFW--GB1-0", size: size + 4))
//                .minimumScaleFactor(0.7)
        } else {
            return
                content
                .font(.custom("Splatfont", size: size))
//                .minimumScaleFactor(0.7)
        }
    }
}

struct Splatfont2: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        if NSLocale.preferredLanguages[0].prefix(2) == "zh" {
            return
                content
                .font(.custom("FZYHFW--GB1-0", size: size))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        } else {
            return
                content
                .font(.custom("Splatfont2", size: size))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        //            .frame(height: size)
    }
}
