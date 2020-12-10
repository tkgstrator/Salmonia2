//
//  AchievementView.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-10.
//

import SwiftUI

struct AchievementView: View {
    
    @EnvironmentObject var stats: AchievementCore
    
    var body: some View {
        List {
            Section(header: Text("Boss")) {
                ForEach(stats.boss_counts.indices, id:\.self) { idx in
                    BossStack(stats: $stats.boss_counts[idx])
                }
            }
            Section(header: Text("Special")) {
                ForEach(stats.special_clear_ratio.indices, id:\.self) { idx in
                    SpecialStack(stats: $stats.special_clear_ratio[idx])
                }
            }
        }
        .navigationBarTitle("Achievement")
    }
    
    struct BossStack: View {
        
        @Binding var stats: BossStats
        
        var body: some View {
            HStack {
                Text(stats.name.localized)
                Spacer()
                Text("\(stats.boss_kill_count)")
                    .frame(width: 50)
                Text("\(stats.boss_count)")
                    .frame(width: 50)
            }
            .font(.custom("Splatfont2", size: 16))
        }
    }
    
    struct SpecialStack: View {
        
        @Binding var stats: SpecialStats
        
        var body: some View {
            HStack {
                Text(stats.name!.localized)
                Spacer()
                Text("\(stats.ratio.per)")
                    .frame(width: 60)
            }
            .font(.custom("Splatfont2", size: 16))
        }
    }
    
}

struct AchievementView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementView()
    }
}
