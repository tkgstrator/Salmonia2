//
//  ResultCollectionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage
import RealmSwift

struct ResultCollectionView: View {
    
    @ObservedObject var core =  UserResultCore()
    @State var isVisible: Bool = false
    @State var sliderValue: Double = 0
    @State var isEnable: [Bool] = [true, true, true, true, true]
//    @State var results: RealmSwift.Results<CoopResultsRealm> = try! Realm().objects(CoopResultsRealm.self)
    
    var body: some View {
        List {
            ForEach(core.results.indices, id:\.self) { idx in
                NavigationLink(destination: ResultView(data: core.results[idx])) {
                    ResultStack(data: core.results[idx])
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
                    }.sheet(isPresented: $isVisible) {
                        ResultFilterView(core: core, sliderValue: $sliderValue, isEnable: $isEnable)
                    }
                }
        )
    }
}

private struct ResultStack: View {
    
    private var danger_rate: Double
    private var job_result_is_clear: Bool
    private var job_result_failure_wave: Int = 0
    private var golden_eggs: Int = 0
    private var power_eggs: Int = 0
    
    init(data: CoopResultsRealm) {
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

private struct ResultFilterView: View {
    
    @ObservedObject var core: UserResultCore
    @Binding var sliderValue: Double
    @Binding var isEnable: [Bool]
    
    func update() {
        var list: [Int] = []
        for (idx, enable) in isEnable.enumerated() {
            if enable { list.append(5000 + idx) }
        }
        core.update(Int(self.sliderValue), list)
    }
    
    var body: some View {
        List {
            Section(header: HStack {
                Spacer()
                Text("Golden Eggs").modifier(Splatfont(size: 22)).foregroundColor(.yellow)
                Spacer()
            }) {
                VStack(spacing: 5) {
                    Slider(value: $sliderValue,
                           in: 0 ... 200,
                           step: 1,
                           onEditingChanged: { pressed in
                            update()
                           },
                           minimumValueLabel: Text("0").modifier(Splatfont(size: 16)),
                           maximumValueLabel: Text("200").modifier(Splatfont(size: 16)),
                           label: { EmptyView() }
                    ).accentColor(.yellow)
                    Text("\(Int(sliderValue))").modifier(Splatfont(size: 20))
                }
            }
            Section(header: HStack {
                Spacer()
                Text("Stage").modifier(Splatfont(size: 22)).foregroundColor(.yellow)
                Spacer()
            }) {
                ForEach(Range(0 ... 4)) { idx in
                    Toggle(isOn: $isEnable[idx]) {
                        Text(StageType.allCases[idx].stage_name!.localized).modifier(Splatfont(size: 20))
                    }
                }
            }
        }.onDisappear() {
            var list: [Int] = []
            for (idx, enable) in isEnable.enumerated() {
                if enable { list.append(5000 + idx) }
            }
            core.update(Int(sliderValue), list)
        }
    }
}

private struct ResultFilterStack: View {
    
    var stage_name: String = ""
    
    init(_ name: String) {
        stage_name = name
    }
    
    var body: some View {
        HStack {
            URLImage(FImage.getURL(5000, 0),
                     content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)).saturation(1.0)})
                .frame(width: 144, height: 81).onTapGesture {
                    //                    self.isEnable[0].toggle()
                    //                    self.update()
                }
            Spacer()
            Text("Spawning Grounds")
            Spacer()
        }
    }
}

struct ResultCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultCollectionView()
    }
}