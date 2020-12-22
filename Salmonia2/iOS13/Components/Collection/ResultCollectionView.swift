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
    @ObservedObject var core: UserResultCore
    @State var isVisible: Bool = false
    @State var sliderValue: Double = 0
    @State var isEnable: [Bool] = [true, true, true, true, true]
    @State var isPersonal: Bool = false
    
    var body: some View {
        List {
            ForEach(core.results.indices, id:\.self) { idx in
                NavigationLink(destination: ResultView(result: core.results[idx])) {
                    ResultStack(result: core.results[idx], isPersonal: $isPersonal)
                }
            }
        }
        .navigationBarTitle("Results")
        .navigationBarItems(trailing: AddButton)
    }
    
    private var AddButton: some View {
        HStack(spacing: 15) {
//            NavigationLink(destination: LoadingView())
//            {
//                URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!) { image in image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
//                    .frame(width: 30, height: 30)
//            }
            Image(systemName: "person.circle.fill")
                .Modifier(isPersonal)
                .onTapGesture() { isPersonal.toggle() }
            Image(systemName: "magnifyingglass")
                .Modifier()
                .onTapGesture() { isVisible.toggle() }
                .sheet(isPresented: $isVisible) {
                ResultFilterView(core: core, sliderValue: $sliderValue, isEnable: $isEnable)
            }
        }
        
    }
    
    private struct ResultStack: View {
        @ObservedObject var result: CoopResultsRealm
        @Binding var isPersonal: Bool
        
        var body: some View {
            HStack {
                Group {
                    if result.is_clear {
                        Text("Clear!")
                            .foregroundColor(.green)
                    } else {
                        VStack {
                            Text("Defeat")
                                .frame(height: 16)
                            HStack {
                                Text("Wave")
                                    .frame(height: 11)
                                Text("\(result.failure_wave.value!)")
                                    .frame(height: 11)
                            }
                        }
                        .foregroundColor(.orange)
                    }
                }
                .modifier(Splatfont(size: 16))
                .frame(minWidth: 80)
                
                Text(String(result.danger_rate)+"%")
                    .font(.custom("Splatfont", size: 16))
                Spacer()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 20, height: 20)
                        if isPersonal {
                            Text("x\(result.player.first!.golden_ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                        } else {
                            Text("x\(result.golden_eggs)").frame(width: 50, height: 16, alignment: .leading)
                        }
                    }
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                            .frame(width: 20, height: 20)
                        if isPersonal {
                            Text("x\(result.player.first!.ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                        } else {
                            Text("x\(result.power_eggs)").frame(width: 50, height: 16, alignment: .leading)
                        }
                    }
                }
                .frame(width: 80)
                .font(.custom("Splatfont2", size: 16))
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
                    Text("Golden Eggs")
                        .modifier(Splatfont2(size: 18))
                        .foregroundColor(.yellow)
                    Spacer()
                }) {
                    VStack(spacing: 5) {
                        Slider(value: $sliderValue,
                               in: 0 ... 200,
                               step: 1,
                               onEditingChanged: { pressed in
                                update()
                               },
                               minimumValueLabel: Text("0").modifier(Splatfont2(size: 16)),
                               maximumValueLabel: Text("200").modifier(Splatfont2(size: 16)),
                               label: { EmptyView() }
                        ).accentColor(.yellow)
                        Text("\(Int(sliderValue))").modifier(Splatfont2(size: 18))
                    }
                }
                Section(header: HStack {
                    Spacer()
                    Text("Stage").modifier(Splatfont2(size: 18)).foregroundColor(.yellow)
                    Spacer()
                }) {
                    ForEach(Range(0 ... 4)) { idx in
                        Toggle(StageType.allCases[idx].stage_name!.localized, isOn: $isEnable[idx])
                            .modifier(Splatfont2(size: 16))
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
        ResultCollectionView(core: UserResultCore())
    }
}
