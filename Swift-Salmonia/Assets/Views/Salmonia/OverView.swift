//
//  OverView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import RealmSwift
import URLImage
import Combine

class UserOverViewModel: ObservableObject {
    private var token: NotificationToken? // 変更を伝えるトークン
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
    
    @Published var job_count: Int?
    @Published var ikura_total: Int?
    @Published var golden_ikura_total: Int?
    @Published var kuma_point_total: Int?
    @Published var help_count: Int?
    
    // これ、こういう型つくりたいよな？？
    @Published var records = Enum().Records // レコード型配列にしたいので要リファクタリング
    @Published var overview: [(eggs: Int?, grade: Int?)] = [(nil, nil),(nil, nil),(nil, nil),(nil, nil),(nil, nil),(nil, nil)] // クソだせえｗｗ
    
    init() {
        // リアルタイム更新のためのメソッド
        token = realm?.observe{ _ in
            // realmに変更があったときだけ呼ばれる
            // publishedの値を変更する（これによってViewの再レンダリングが行われる
            guard let card = try? Realm().objects(CoopCardRealm.self).first else { return } // Optionalを外す処理
            guard let results = try? Realm().objects(CoopResultsRealm.self) else { return }
            
            self.job_count = card.job_num
            self.ikura_total = card.ikura_total
            self.golden_ikura_total = card.golden_ikura_total
            
            for (i, stage) in Enum().Stage.map({ $0.name }).enumerated() {
                // そのステージのWAVEだけ抜き出す mapとfilterで上手く書けなかった
                let stage_records = results.lazy.filter({$0.stage_name == stage}).lazy.map({ $0.wave })
                let wave_records = RealmSwift.List<WaveDetailRealm>()
                for waves in stage_records {
                    for wave in waves {
                        wave_records.append(wave)
                    }
                }
                // イベントと潮位ごとに最高納品数を取得
                for (j, event) in Enum().Event.enumerated() {
                    for (k, tide) in Enum().Tide.enumerated() {
                        // ここで謎のオプショナル型宣言は何？あるんですけど？？？
                        self.records[i]![j]![k] = wave_records.filter({$0.event_type == event && $0.water_level == tide}).map{ $0.golden_ikura_num }.max()
                    }
                }
                // 最高レートと納品数を取得
                self.overview[i].eggs = results.filter("stage_name=%@", stage).max(ofProperty: "golden_eggs")
                self.overview[i].grade = results.filter("stage_name=%@", stage).max(ofProperty: "grade_point")
            }
            // 全ステージのまとめ
            self.overview[5].eggs = results.max(ofProperty: "golden_eggs")
            self.overview[5].grade = results.max(ofProperty: "grade_point")
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

struct StageStack: View {
    private var grade_point: Int?
    private var golden_eggs: Int?
    private var stage: String?
    private var records: [Int: [Int?]]
    private var url: String = "https://app.splatoon2.nintendo.net/images/bundled/8c15ceb605300fbc22963fabcb09fb22.png" // 画像のプレースホルダ（設定しておかないとURLImageがクラッシュする）
    
    init(stage: String, value: [Int: [Int?]], overview: (eggs: Int?, grade: Int?) ){
        // Privateな変数に値を代入する（いちいちコピーするのめんどくさい気もするが...
        self.grade_point = overview.grade
        self.golden_eggs = overview.eggs
        self.records = value
        self.stage = stage
        guard let imageUri = Enum().Stage.filter({ $0.name == stage }).first?.url else { return }
        url = "https://app.splatoon2.nintendo.net/images/coop_stage/" + imageUri
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: StageRecordsView(name: stage, value: records)) {
                URLImage(URL(string: url)!, content: {$0.image.renderingMode(.original).resizable().aspectRatio(contentMode: .fill)})
                    .frame(width: 110, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
            HStack {
                Text(grade_point.string).foregroundColor(.red)
                Text(golden_eggs.string).foregroundColor(.yellow)
            }
            .font(.custom("Splatfont2", size: 18))
            .padding(.top, 0)
        }
    }
}


struct OverView: View {
    @ObservedObject var data = UserOverViewModel()
    
    var body: some View {
        ScrollView {
            StatsColumn(title: "JOB COUNT", value: data.job_count)
            StatsColumn(title: "TOTAL POWER EGGS", value: data.ikura_total)
            StatsColumn(title: "TOTAL GOLDEN EGGS", value: data.golden_ikura_total)
            VStack(spacing: 0) {
                // ここもなんでアンラップしないといけないのかわからん
                HStack {
                    StageStack(stage: "Spawning Grounds", value: data.records[0]!, overview: data.overview[0])
                    Spacer()
                    StageStack(stage: "Marooner's Bay", value: data.records[1]!, overview: data.overview[1])
                    Spacer()
                    StageStack(stage: "Lost Outpost", value: data.records[2]!, overview: data.overview[2])
                }
                HStack {
                    StageStack(stage: "Salmonid Smokeyard", value: data.records[3]!, overview: data.overview[3])
                    Spacer()
                    StageStack(stage: "Ruins of Ark Polaris", value: data.records[4]!, overview: data.overview[4])
                    Spacer()
                    StageStack(stage: "All", value: data.records[5]!, overview: data.overview[5])
                }
            }
        }
    }
}

//struct OverView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverView()
//    }
//}
