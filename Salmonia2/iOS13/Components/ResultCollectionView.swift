//
//  ResultCollectionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct ResultCollectionView: View {
    
    @EnvironmentObject var core: UserResultCore
    
    var body: some View {
        List {
            ForEach(core.results.indices, id:\.self) { idx in
                NavigationLink(destination: ResultView(data: core.results[idx])) {
                    ResultStack(data: self.core.results[idx])
                }
            }
        }
        .navigationBarTitle("Results")
    }
}

private struct ResultStack: View {
    //    private var grade_point: Int = 0
    private var danger_rate: Double
    private var job_result_is_clear: Bool
    private var job_result_failure_wave: Int = 0
    private var golden_eggs: Int = 0
    private var power_eggs: Int = 0
    
    init(data: CoopResultsRealm) {
        //        grade_point = data.grade_point.value ?? 0
        danger_rate = data.danger_rate
        job_result_is_clear = data.is_clear
        job_result_failure_wave = data.failure_wave.value ?? 0
        golden_eggs = data.golden_eggs
        power_eggs = data.power_eggs
    }
    
    var body: some View {
        HStack {
            Group {
                if job_result_is_clear {
                    Text("Clear!").foregroundColor(.green).font(.custom("Splatfont", size: 16))
                } else {
                    VStack {
                        Text("Defeat").frame(height: 16).font(.custom("Splatfont", size: 16))
                        HStack {
                            Text("Wave").frame(height: 11)
                            Text("\(job_result_failure_wave)").frame(height: 11)
                        }
                    }
                    .foregroundColor(.orange)
                    .font(.custom("Splatfont", size: 14))
                }
                
            }.frame(width: 60).font(.custom("Splatfont", size: 16))
            // ブキとか？
            // 金イクラ数とかの情報（イカリング2準拠スタイル）
            Text(String(danger_rate)+"%").font(.custom("Splatfont", size: 16))
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(golden_eggs)").frame(width: 50, height: 16, alignment: .leading)
                }
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(power_eggs)").frame(width: 50, height: 16, alignment: .leading)
                }
            }.frame(width: 80).font(.custom("Splatfont2", size: 16))
        }
    }
}

struct ResultCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultCollectionView()
    }
}
