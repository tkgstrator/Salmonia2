//
//  Model.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine

class RealmModel: ObservableObject {
    // いろんなモデルの集合体のようなもの
    @ObservedObject var userinfo = UserInfoModel()

    init() {
        
    }
}

 class UserInfoModel: ObservableObject {
     private var infoToken: NotificationToken?
     private var resultToken: NotificationToken?

     @Published var information: UserInformation = UserInformation()
     
     init() {
         //  ユーザ情報に変更があったときに呼び出す
         infoToken = try? Realm().objects(UserInfoRealm.self).observe{ _ in
             self.update()
         }
         
         // リザルト情報に変更があったときに呼び出す
         resultToken = try? Realm().objects(CoopResultsRealm.self).observe{ _ in
             self.update()
         }
     }
     
     func update() {
         // 変更があったときに実行されるハンドラ
         self.information = UserInformation(name: nil, url: nil, iksm_session: nil, session_token: nil, api_token: nil)
         guard let user = try? Realm().objects(UserInfoRealm.self).first else { return }
         guard let card = try? Realm().objects(CoopCardRealm.self).first else { return }
         guard let results = try? Realm().objects(CoopResultsRealm.self) else { return }
         
         self.information = UserInformation(name: user.name, url: user.image, iksm_session: user.iksm_session, session_token: user.session_token, api_token: user.api_token)
         self.information.overview = PlayerOverview(job_count: card.job_num, ikura_total: card.ikura_total, golden_ikura_total: card.golden_ikura_total, kuma_point_total: card.kuma_point_total)
         
         for (i, stage) in Enum().Stage.map({ $0.name }).enumerated() {
             // そのステージのWAVEだけ抜き出す mapとfilterで上手く書けなかった
             let stage_records = results.lazy.filter({$0.stage_name == stage}).lazy.map({ $0.wave })
             let wave_records = RealmSwift.List<WaveDetailRealm>()
             for waves in stage_records {
                 for wave in waves {
                     wave_records.append(wave)
                 }
             }
             self.information.records[i].grade_point = results.filter("stage_name=%@", stage).max(ofProperty: "grade_point")
             self.information.records[i].team_golden_eggs =  results.filter("stage_name=%@", stage).max(ofProperty: "golden_eggs")
             // イベントと潮位ごとに最高納品数を取得
             for (j, event) in Enum().Event.enumerated() {
                 for (k, tide) in Enum().Tide.enumerated() {
                     let eggs = wave_records.filter({$0.event_type == event && $0.water_level == tide}).map{ $0.golden_ikura_num }.max()
                     self.information.records[i].set(event: k, tide: j, value: eggs)
                 }
             }
         }
     }
 }

class ResultsModel: ObservableObject {
    private var token: NotificationToken? // 変更を伝えるトークン
    public let realm = try? Realm().objects(CoopResultsRealm.self) // 監視対象
    
    @Published var data: [ResultCollection] = []
    
    init() {
        // リアルタイム更新のためのメソッド
        token = realm?.observe{ _ in
            self.data = [] // このコードダッサｗｗｗｗｗ
            guard let results = self.realm?.sorted(byKeyPath: "play_time", ascending: false).prefix(10).map({$0}) else { return }
            // とりあえず最新の十件とれるようにするか？
            for result in results {
                self.data.append(ResultCollection(job_id: result.job_id, danger_rate: result.danger_rate, is_clear: result.job_result_is_clear, weapons: result.player[0].weapon, special: result.player[0].special_id, golden_eggs: result.golden_eggs, power_eggs: result.power_eggs))
            }
        }
    }
}
