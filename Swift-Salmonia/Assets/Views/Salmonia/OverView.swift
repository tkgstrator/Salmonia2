//
//  OverView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import Combine
import RealmSwift
import URLImage

class UserOverViewModel: ObservableObject {
    private var token: NotificationToken? // 変更を伝えるトークン
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
    @Published var job_count: Int?
    @Published var ikura_total: Int?
    @Published var golden_ikura_total: Int?
    @Published var kuma_point_total: Int?
    @Published var help_count: Int?
    @Published var stacks: [(golden_eggs: Int?, grade_point: Int?)] = [(nil, nil),(nil, nil),(nil, nil),(nil, nil),(nil, nil),(nil, nil)]

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
                let golden_eggs: Int? = results.filter("stage_name=%@", stage).max(ofProperty: "golden_eggs")
                let grade_point: Int? = results.filter("stage_name=%@", stage).max(ofProperty: "grade_point")
                self.stacks[i] = (golden_eggs: golden_eggs, grade_point: grade_point)
            }
            let golden_eggs: Int? = results.max(ofProperty: "golden_eggs")
            let grade_point: Int? = results.max(ofProperty: "grade_point")
            self.stacks[5] = (golden_eggs: golden_eggs, grade_point: grade_point)
        }
    }
    
    deinit {
        token?.invalidate()
    }
}

struct StageStack: View {
    private var grade_point: Int?
    private var golden_eggs: Int?
    private var url: String = "https://app.splatoon2.nintendo.net/images/bundled/8c15ceb605300fbc22963fabcb09fb22.png"
    
    init(stage: String, value:(grade_point: Int?, golden_eggs: Int?)){
        self.grade_point = value.grade_point
        self.golden_eggs = value.golden_eggs
        guard let imageUri = Enum().Stage.filter({ $0.name == stage }).first?.url else { return }
        url = "https://app.splatoon2.nintendo.net/images/coop_stage/" + imageUri
    }
    
    var body: some View {
        VStack(spacing: 0) {
            URLImage(URL(string: url)!, content:  {$0.image.resizable().aspectRatio(contentMode: .fill)})
                .frame(width: 110, height: 60)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
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
    @ObservedObject var overview = UserOverViewModel()
    
    var body: some View {
        ScrollView {
            StatsColumn(title: "JOB COUNT", value: overview.job_count)
            StatsColumn(title: "TOTAL POWER EGGS", value: overview.ikura_total)
            StatsColumn(title: "TOTAL GOLDEN EGGS", value: overview.golden_ikura_total)
            VStack(spacing: 0) {
                HStack {
                    StageStack(stage: "Spawning Grounds", value: overview.stacks[0])
                    Spacer()
                    StageStack(stage: "Marooner's Bay", value: overview.stacks[1])
                    Spacer()
                    StageStack(stage: "Lost Outpost", value: overview.stacks[2])
                }
                HStack {
                    StageStack(stage: "Salmonid Smokeyard", value: overview.stacks[3])
                    Spacer()
                    StageStack(stage: "Ruins of Ark Polaris", value: overview.stacks[4])
                    Spacer()
                    StageStack(stage: "All", value: overview.stacks[4])
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
