//
//  ResultsCollectionView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-31.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import Combine
import URLImage
import RealmSwift

class ResultsModel: ObservableObject {
    private var token: NotificationToken? // 変更を伝えるトークン
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
    
    @Published var data: [ResultAbout] = []
    
    init() {
        // リアルタイム更新のためのメソッド
        token = realm?.observe{ _ in
            self.data = [] // このコードダッサｗｗｗｗｗ
            guard let results = self.realm?.sorted(byKeyPath: "play_time", ascending: false).prefix(10).map({$0}) else { return }
            // とりあえず最新の十件とれるようにするか？
            for result in results {
                self.data.append(ResultAbout(danger_rate: result.danger_rate, is_clear: result.job_result_is_clear, weapons: result.player[0].weapon, special: result.player[0].special_id, golden_eggs: result.golden_eggs, power_eggs: result.power_eggs))
            }
        }
    }
}

struct ResultStack: View {
    private var result: ResultAbout
    
    init(data: ResultAbout) {
        result = data
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack {
                Text(result.danger_rate.string + "%")
                Spacer()
                Group {
                    ForEach(result.weapons, id: \.self) { weapon in
                        URLImage(URL(string: weapon.weapon)!, content: {$0.image.resizable().frame(width: 30, height: 30)
                        })
                    }
                }
            }
            HStack {
                Group {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text(result.golden_eggs.string).frame(width: 30)
                    Spacer()
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 20, height: 20)
                    Text(result.power_eggs.string).frame(width: 45)
                    Spacer()
                }
                Group {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!, content: {$0.image.resizable()})
                        .frame(width: 50, height: 20)
                    Text("99").frame(width: 30)
                    Spacer()
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!, content: {$0.image.resizable()})
                        .frame(width: 50, height: 20)
                    Text("99").frame(width: 30)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .font(.custom("Splatfont2", size: 18))
        //        .background(Color.orange)
    }
}

struct ResultsCollectionView: View {
    @ObservedObject var results = ResultsModel()
    
    var body: some View {
        List {
            ForEach(results.data, id: \.self) { result in
                ResultStack(data: result)
            }
        }
        .navigationBarTitle("Results")
    }
}

struct ResultsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsCollectionView()
    }
}
