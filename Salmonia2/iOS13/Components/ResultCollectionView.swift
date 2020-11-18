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
    
    var body: some View {
        Group {
            Text("Found: \(core.results.count)").frame(maxWidth: .infinity)
            .font(.custom("Splatfont", size: 16))
            .frame(height: 10)
            Divider()
            List {
                ForEach(core.results.indices, id:\.self) { idx in
                    NavigationLink(destination: ResultView().environmentObject(core.results[idx])) {
                        ResultStack().environmentObject(core.results[idx])
                    }
                }
            }
        }
        .navigationBarTitle("Results")
//        .navigationBarTitle(Text("Results " + String(core.results.count)), displayMode: .large)
        .navigationBarItems(trailing: AddButton)

    }
    
    private var AddButton: some View {
        HStack(spacing: 15) {
            NavigationLink(destination: LoadingView())
            {
                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                         content: {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                    .frame(width: 30, height: 30)
            }
            Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30).onTapGesture() {
                self.isVisible.toggle()
            }.sheet(isPresented: $isVisible) {
                ResultFilterView(core: core, sliderValue: $sliderValue, isEnable: $isEnable)
            }
        }
        
    }
    
    private struct ResultStack: View {
        @EnvironmentObject var result: CoopResultsRealm
        
        var body: some View {
            HStack {
                Group {
                    if result.is_clear {
                        Text("Clear!").foregroundColor(.green).font(.custom("Splatfont", size: 16))
                    } else {
                        VStack {
                            Text("Defeat").frame(height: 16).font(.custom("Splatfont", size: 16))
                            HStack {
                                Text("Wave").frame(height: 11)
                                Text("\(result.failure_wave.value!)").frame(height: 11)
                            }
                        }
                        .foregroundColor(.orange)
                        .font(.custom("Splatfont", size: 14))
                    }
                }.frame(minWidth: 80).font(.custom("Splatfont", size: 16))
                // ブキとか？
                // 金イクラ数とかの情報（イカリング2準拠スタイル）
                Text(String(result.danger_rate)+"%").font(.custom("Splatfont", size: 16))
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                            .frame(width: 20, height: 20)
                        Text("x\(result.golden_eggs)").frame(width: 50, height: 16, alignment: .leading)
                    }
                    HStack {
                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                            .frame(width: 20, height: 20)
                        Text("x\(result.power_eggs)").frame(width: 50, height: 16, alignment: .leading)
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
}


struct ResultCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultCollectionView()
    }
}
