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
            Section(header: Text("System").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("Navigation Title", isOn: $rainbow.title)
            }
            Section(header: Text("Results").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("Player Grade", isOn: $rainbow.result)
            }
            Section(header: Text("Result Detail").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("Overview", isOn: $rainbow.resultOverview)
                Toggle("Player Name", isOn: $rainbow.resultName)
                Toggle("Wave Quota", isOn: $rainbow.resultQuota)
                Toggle("Details", isOn: $rainbow.resultPlayer)
            }
            Section(header: Text("Shift Stats").font(.custom("Splatfont2", size: 16)).foregroundColor(.cOrange)) {
                Toggle("Parameter", isOn: $rainbow.shiftParam)
                Toggle("Value", isOn: $rainbow.shiftValue)
            }
        }
        .font(.custom("Splatfont2", size: 16))
        .navigationTitle("Gaming Configuration")
    }
}

struct RainbowConfiguration_Previews: PreviewProvider {
    static var previews: some View {
        RainbowConfiguration()
    }
}
