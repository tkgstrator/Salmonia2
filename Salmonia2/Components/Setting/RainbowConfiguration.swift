//
//  RainbowConfiguration.swift
//  Salmonia2
//
//  Created by Devonly on 2021/02/21.
//

import SwiftUI

struct RainbowConfiguration: View {
    @EnvironmentObject var rainbow: RainbowCore
//    @EnvironmentObject var rainbow: RainbowCore

    var body: some View {
        List{
            Section(header: Text("HEADER_SYSTEM").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("GAMING_NAVIGATION_LINK", isOn: $rainbow.title)
            }
            Section(header: Text("HEADER_RESULTS").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("GAMING_PLAYER_GRADE", isOn: $rainbow.result)
            }
            Section(header: Text("HEADER_RESULT_DETAIL").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("GAMING_OVERVIEW", isOn: $rainbow.resultOverview)
                Toggle("GAMING_PLAYER_NAME", isOn: $rainbow.resultName)
                Toggle("GAMING_WAVE_QUOTA", isOn: $rainbow.resultQuota)
                Toggle("GAMING_DETAILS", isOn: $rainbow.resultPlayer)
            }
            Section(header: Text("HEADER_SHIFT_STATS").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("GAMING_PARAMETER", isOn: $rainbow.shiftParam)
                Toggle("GAMING_VALUE", isOn: $rainbow.shiftValue)
            }
        }
        .font(.custom("Splatfont2", size: 16))
        .navigationTitle("TITLE_GAMING_CONFIG")
    }
}

struct RainbowConfiguration_Previews: PreviewProvider {
    static var previews: some View {
        RainbowConfiguration()
    }
}
