//
//  ResultsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct ResultsCollectionView: View {
    @ObservedObject var core = UserResultsCore()
    @State var isVisible: Bool = false
    @State var sliderValue: Double = 0
    @State var isEnable: [Bool] = [true, true, true, true, true]
    
    var body: some View {
        Group {
            HStack {
                Text("Found: \(core.results.count)")
            }
            .font(.custom("Splatoon1", size: 16))
            .frame(height: 10)
            List {
                ForEach(core.results.indices, id:\.self) { idx in
                    NavigationLink(destination: ResultView(data: self.core.results[idx])) {
                        ResultStackView(data: self.core.results[idx])
                    }
                }
            }
        }
        .navigationBarTitle("Results")
        .navigationBarItems(
            trailing:
            HStack {
                NavigationLink(destination: LoadingView())
                {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                             content: {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 30, height: 30)
                }
                Spacer()
                Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
                    self.isVisible.toggle()
                    print("TAP")
                }.sheet(isPresented: $isVisible) {
                    ResultsFilterView(core: self.core, sliderValue: self.$sliderValue, isEnable: self.$isEnable)
                }
            }
        )
    }
}

private struct ResultsFilterView: View {
    @ObservedObject var core: UserResultsCore
    @Binding var sliderValue: Double
    @Binding var isEnable: [Bool]
    
    func update() {
        var list: [Int] = []
        for (i, enable) in self.isEnable.enumerated() {
            if enable { list.append(5000 + i) }
        }
        print(list)
        self.core.update(Int(self.sliderValue), list)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 2) {
                Text("Golden Eggs").font(.custom("Splatoon1", size: 24)).foregroundColor(.yellow).frame(height: 24)
                Slider(value: $sliderValue,
                       in: 0 ... 200,
                       step: 1,
                       onEditingChanged: { pressed in
                        self.update()
                },
                       minimumValueLabel: Text("0").font(.custom("Splatoon1", size: 16)),
                       maximumValueLabel: Text("200").font(.custom("Splatoon1", size: 16)),
                       label: { EmptyView() }
                ).accentColor(.yellow)
                Text("\(Int(sliderValue))")
            }.padding(.horizontal, 10)
            VStack(spacing: 2) {
                Text("Stage").font(.custom("Splatoon1", size: 24)).foregroundColor(.orange)
                VStack {
                    HStack {
                        Spacer()
                        URLImage(URL(string: ImageURL.stage(5000))!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(self.isEnable[0] ? 1.0 : 0.0)})
                            .frame(width: 144, height: 81).onTapGesture {
                                self.isEnable[0].toggle()
                                self.update()
                        }
                        Spacer()
                        URLImage(URL(string: ImageURL.stage(5001))!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(self.isEnable[1] ? 1.0 : 0.0)})
                            .frame(width: 144, height: 81).onTapGesture {
                                self.isEnable[1].toggle()
                                self.update()
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        URLImage(URL(string: ImageURL.stage(5002))!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(self.isEnable[2] ? 1.0 : 0.0)})
                            .frame(width: 144, height: 81).onTapGesture {
                                self.isEnable[2].toggle()
                                self.update()
                        }
                        Spacer()
                        URLImage(URL(string: ImageURL.stage(5003))!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(self.isEnable[3] ? 1.0 : 0.0)})
                            .frame(width: 144, height: 81).onTapGesture {
                                self.isEnable[3].toggle()
                                self.update()
                        }
                        Spacer()
                    }
                    HStack {
                        URLImage(URL(string: ImageURL.stage(5004))!,
                                 content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(self.isEnable[4] ? 1.0 : 0.0)})
                            .frame(width: 144, height: 81).onTapGesture {
                                self.isEnable[4].toggle()
                                self.update()
                        }
                    }
                }
            }
        }.font(.custom("Splatoon1", size: 20))
    }
}


private struct ResultStackView: View {
    private var grade_point: Int?
    private var danger_rate: Double
    private var job_result_is_clear: Bool
    private var job_result_failure_wave: Int?
    private var golden_eggs: Int?
    private var power_eggs: Int?
    
    init(data: CoopResultsRealm) {
        grade_point = data.grade_point.value
        danger_rate = data.danger_rate
        job_result_is_clear = data.is_clear
        job_result_failure_wave = data.failure_wave.value
        golden_eggs = data.golden_eggs
        power_eggs = data.power_eggs
    }
    
    var body: some View {
        HStack {
            Group {
                if job_result_is_clear {
                    Text("Clear!").foregroundColor(.green).font(.custom("Splatoon1", size: 16))
                } else {
                    VStack {
                        Text("Defeat").frame(height: 16).font(.custom("Splatoon1", size: 16))
                        HStack {
                            Text("Wave").frame(height: 11)
                            Text("\(job_result_failure_wave.value)").frame(height: 11)
                        }
                    }
                    .foregroundColor(.orange)
                    .font(.custom("Splatoon1", size: 14))
                }
                
            }.frame(width: 60).font(.custom("Splatoon1", size: 16))
            // ブキとか？
            // 金イクラ数とかの情報（イカリング2準拠スタイル）
            Text(String(danger_rate)+"%").font(.custom("Splatoon1", size: 16))
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
