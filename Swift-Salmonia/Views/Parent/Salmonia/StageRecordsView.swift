//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift

struct GoldenEggRecordsView: View {
    @State var threshold: Double = 100
//    @State var records: [CoopResultsRealm] = []
    @State var percentage: Double = 0.0
    @State var avg_power_eggs: Double = 0.0
    @State var avg_golden_eggs: Double = 0.0

//    @ObservedObject var stage = UserResultsCore()
    
    var body: some View {
        Group {
            VStack(spacing: 0) {
                Text("Golden Eggs: \(Int(threshold))").foregroundColor(.yellow)
                Slider(value: $threshold, in: 50...200, step: 1, onEditingChanged: { _ in
                    // オブジェクト自体を更新
//                    self.records = Array(self.stage.results.filter("golden_eggs>=%@", Int(self.threshold)))
//                    self.percentage = (Double(self.records.count) / Double(self.stage.results.count)).round(digit: 2)
//                    self.avg_power_eggs = (Double(self.records.map({ $0.power_eggs }).reduce(0, +)) / Double(self.records.count)).round(digit: 2)
//                    self.avg_golden_eggs = (Double(self.records.map({ $0.golden_eggs }).reduce(0, +)) / Double(self.records.count)).round(digit: 2)
                })
            }
            List {
                HStack {
                    Text("Records")
                    Spacer()
//                    Text("\(records.count)")
                }
                HStack {
                    Text("Percentage")
                    Spacer()
                    Text(String(percentage))
                }
                HStack {
                    Text("Avg Power Eggs")
                    Spacer()
                    Text(String(avg_power_eggs))
                }
                HStack {
                    Text("Avg Golden Eggs")
                    Spacer()
                    Text(String(avg_golden_eggs))
                }
            }
        }.onAppear(){
            #if DEBUG
//            self.records = Array(self.stage.results.filter("golden_eggs>=%@", Int(self.threshold)))
//            self.percentage = (Double(self.records.count) / Double(self.stage.results.count)).round(digit: 2)
            #endif
        }
        .navigationBarTitle("Stage Stats")
    }
}

//struct GoldenEggRecordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}
