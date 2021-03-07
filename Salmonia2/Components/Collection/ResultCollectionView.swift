//
//  ResultCollectionView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import SwiftUIRefresh
import URLImage
import RealmSwift

struct ResultCollectionView: View {
    @ObservedObject var core: UserResultCore
    
    @State var isVisible: Bool = false
    @State var sliderValue: Double = 0
    @State var isEnable: [Bool] = [true, true, true, true, true]
    @State var isActive: Bool = false
    @State var isPersonal: Bool = false
    @State private var isShowing: Bool = false
    @State private var isDebugLog: Bool = false
    @State private var debugMessage: String = ""
    @State private var debugCode: Int = 9999
    @State private var debugDescription: String = ""
    
    var body: some View {
        ZStack {
            List {
                ForEach(core.data.indices, id:\.self) { idx in
                    CoopShiftStack(phase: core.data[idx].phase)
                    ForEach(core.data[idx].results, id:\.self) { result in
                        NavigationLink(destination: ResultView(result: result)) {
                            ResultStack(result: result, isPersonal: $isPersonal)
                        }
                    }
                }
            }
            NavigationLink(destination: LoadingView(), isActive: $isActive) { EmptyView() }
        }
        .pullToRefresh(isShowing: $isShowing) { isActive.toggle() }
        .alert(isPresented: $isDebugLog) {
            Alert(title: Text("DEF_ERROR_CODE".localized + String(debugCode)), message: Text(debugMessage.localized))
        }
        .navigationTitle("TITLE_RESULT_DETAIL")
        .navigationBarItems(trailing: AddButton)
    }
    
    private var AddButton: some View {
        HStack(spacing: 15) {
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
        @EnvironmentObject var rainbow: RainbowCore
        @Binding var isPersonal: Bool
        var gradeID: [String] = ["Intern", "Apparentice","Part-Timer", "Go-Getter", "Overachiever", "Profreshional"]
        
        var body: some View {
            HStack {
                JobResult
                Spacer()
                RateDelta
                Spacer()
                EggResult
            }
            .font(.custom("Splatfont", size: 14))
        }
        
        var EggResult: some View {
            VStack(alignment: .leading, spacing: 5) {
                switch isPersonal {
                case true: // 個人成績を表示
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(result.player.first!.golden_ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                    }
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(result.player.first!.ikura_num)").frame(width: 50, height: 16, alignment: .leading)
                    }
                case false: // チーム成績を表示
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(result.golden_eggs)").frame(width: 50, height: 16, alignment: .leading)
                    }
                    HStack {
                        URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!) { image in image.resizable()}
                            .frame(width: 18, height: 18)
                        Text("x\(result.power_eggs)").frame(width: 50, height: 16, alignment: .leading)
                    }
                }
            }
            .frame(width: 55)
            .font(.custom("Splatfont2", size: 14))
        }
        
        var JobResult: some View {
            switch result.is_clear {
            case true:
                return AnyView(ZStack(alignment: .topLeading) {
                    Text(String(result.id))
                        .offset(y: -10)
                        .font(.custom("Splatfont2", size: 9))
                        .foregroundColor(.cGray)
                    Text("Clear!")
                        .foregroundColor(.green)
                        .font(.custom("Splatfont", size: 14))
                })
                .frame(width: 50, height: 30)
            case false:
                return AnyView(ZStack(alignment: .topLeading) {
                    Text(String(result.id))
                        .offset(y: -10)
                        .font(.custom("Splatfont2", size: 9))
                        .foregroundColor(.cGray)
                    Text("Defeat")
                        .foregroundColor(.cOrange)
                        .font(.custom("Splatfont", size: 14))
                })
                .frame(width: 50, height: 30)
            }
        }
        
        var RateDelta: some View {
            switch (!isPersonal, result.grade_point.value != nil) {
            case (true, true): // レート表示
                switch result.failure_wave.value {
                case nil: // クリアした場合
                    return AnyView(Group {
                        Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                            .rainbow(rainbow.result)
                        Text("\(result.grade_point.value!)")
                            .rainbow(rainbow.result)
                        Text("↑")
                            .foregroundColor(.cRed)
                            .font(.custom("Splatfont", size: 20))
                    })
                case 3: // WAVE3で失敗
                    return AnyView( Group {
                        Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                        Text("\(result.grade_point.value!)")
                        Text("→")
                            .font(.custom("Splatfont", size: 20))
                    }.foregroundColor(.cGray))
                case 2: // WAVE1で失敗
                    return AnyView (Group {
                        Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                        Text("\(result.grade_point.value!)")
                        Text("↓")
                            .font(.custom("Splatfont", size: 20))
                    }.foregroundColor(.cGray))
                case 1: // WAVE1で失敗
                    return AnyView (Group {
                        Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                        Text("\(result.grade_point.value!)")
                        Text("↓")
                            .font(.custom("Splatfont", size: 20))
                    }.foregroundColor(.cGray))
                default:
                    return AnyView(EmptyView())
                }
            case (true, false): // キケン度表示
                return AnyView(Group {
                    Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                    Text(String(result.danger_rate)+"%")
                })
            case (false, true): // キケン度表示
                return AnyView(Group {
                    Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                    Text(String(result.danger_rate)+"%")
                })
            case (false, false):
                return AnyView(Group {
                    Text("\(gradeID[result.grade_id.value ?? 5].localized)")
                    Text(String(result.danger_rate)+"%")
                })
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
