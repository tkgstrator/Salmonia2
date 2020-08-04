//
//  ResultsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import URLImage

struct ResultsCollectionView: View {
    @ObservedObject var core = UserResultsCore()
    
    var body: some View {
        List {
            ForEach(core.results, id: \.self) { result in
                NavigationLink(destination: ResultView()) {
                    ResultStackView(data: result)
                }
            }
        }.navigationBarTitle("Results")
    }
}

private struct ResultStackView: View {
    private var grade_point: Int?
    private var job_result_is_clear: Bool
    private var job_result_failure_wave: Int?
    private var golden_eggs: Int?
    private var power_eggs: Int?
    
    init(data: CoopResultsRealm) {
        grade_point = data.grade_point
        job_result_is_clear = data.job_result_is_clear
        job_result_failure_wave = data.job_result_failure_wave.value
        golden_eggs = data.golden_eggs
        power_eggs = data.power_eggs
    }
    
    var body: some View {
        HStack {
            // クリアしたかの情報（色をつけたい所存）
            Group {
                if job_result_is_clear {
                    Text("Clear!")
                } else {
                    VStack {
                        Text("Defeat").frame(height: 14)
                        HStack {
                            Text("Wave").frame(height: 11)
                            Text("\(job_result_failure_wave.value)").frame(height: 11)
                        }.font(.custom("Splatoon1", size: 11))
                    }
                }
                
            }.frame(width: 60).font(.custom("Splatoon1", size: 14))
            // ブキとか？
            // 金イクラ数とかの情報（イカリング2準拠スタイル）
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(golden_eggs.value)").frame(width: 50, height: 16, alignment: .leading)
                }
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text("x\(power_eggs.value)").frame(width: 50, height: 16, alignment: .leading)
                }
            }.frame(width: 80).font(.custom("Splatfont2", size: 16))
        }
    }
    
}

struct ResultsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsCollectionView()
    }
}
