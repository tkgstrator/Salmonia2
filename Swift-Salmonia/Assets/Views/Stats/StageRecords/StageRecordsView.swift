//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-29.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import RealmSwift
import Combine

private struct RecordStack: View {
    private var record: (high: String, normal: String, low: String)
    private var title: String
    
    init(wave: String, value: [Int?]?) {
        title = wave
        // なんで[Int?]?が入ってるのかわからん
        record.high = value![2].string
        record.normal = value![1].string
        record.low = value![0].string
    }
    
    var body: some View {
        Section(header: Text(title).font(.custom("Splatfont2", size: 24))) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Image("low").renderingMode(.original).resizable().scaledToFit().frame(width: 100, height: 100).background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .overlay(ImageOverlay(record: record.low), alignment: .center)
                }
                Spacer()
                VStack(spacing: 0) {
                    Image("normal").renderingMode(.original).resizable().scaledToFit().frame(width: 100, height: 100).background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .overlay(ImageOverlay(record: record.normal), alignment: .center)
                }
                Spacer()
                VStack(spacing: 0) {
                    Image("high").renderingMode(.original).resizable().scaledToFit().frame(width: 100, height: 100).background(Color.yellow).clipShape(RoundedRectangle(cornerRadius: 8.0))
                        .overlay(ImageOverlay(record: record.high), alignment: .center)
                }
            }
        }
    }
}

private struct ImageOverlay: View {
    private var golden_eggs: String
    
    init(record: String) {
        golden_eggs = record
    }
    var body: some View {
        ZStack {
            Text(golden_eggs).font(.custom("Splatoon1", size: 34)).foregroundColor(.black)
        }
    }
}

struct StageRecordsView: View {
    
    private var stage: String
    private var records: [Int: [Int?]]
    
    init(name: String?, value: [Int: [Int?]]) {
        records = value
        stage = name ?? "-" // 大丈夫だと思うが、一応クラッシュ避けのため
    }
    
    var body: some View {
        List {
            VStack(spacing: 0) {
                RecordStack(wave: "None", value: records[0])
                RecordStack(wave: "Rush", value: records[1])
                RecordStack(wave: "Goldie Seeking", value: records[2])
                RecordStack(wave: "The Griller", value: records[3])
                RecordStack(wave: "The Mothership", value: records[4])
                RecordStack(wave: "Fog", value: records[5])
                RecordStack(wave: "Cohock Charge", value: records[6])
            }
        }
        .font(.custom("Splatfont2", size: 18)).padding(0)
        .navigationBarTitle(stage)
    }
}

//struct StageRecordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StageRecordsView(ti)
//    }
//}
