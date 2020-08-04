//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON

struct LoadingView: View {
    @State var messages: [String] = []
    
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Logging Thread").frame(maxWidth: .infinity)
                    ForEach(messages.indices, id: \.self) { idx in
                        Text(self.messages[idx])
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 14))
        .onAppear() {
            guard let realm = try? Realm() else { return }
            self.messages.append("Getting Summary Card")
            SplatNet2.getSummaryFromSplatNet2() { response in
                // エラーが出ていたらiksm_sessionを再生成する（ダサくね？
                // 別にvalidation用意したほうが良くね？
                guard let nsaid = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
                
                // カード情報を更新する
                let card = CoopCardRealm()
                let value = response["summary"]["card"]
                card.nsaid = nsaid
                card.job_num = value["job_num"].intValue
                card.ikura_total = value["ikura_total"].intValue
                card.golden_ikura_total = value["golden_ikura_total"].intValue
                card.kuma_point = value["kuma_point"].intValue
                card.kuma_point_total = value["kuma_point_total"].intValue
                card.help_total = value["help_total"].intValue
                try? realm.write {
                    realm.add(card, update: .modified)
                }
                for (i, stats) in response["summary"]["stats"] {
                    // 5件しかないと思うんだが、やたらとカウントされるので3で割ってみた
                    self.messages.append("Getting Shift Summary [\(i)/\(stats.count / 3)]")
                    let summary = ShiftResultsRealm()
                    
                    summary.configure(nsaid: nsaid, start_time: stats["start_time"].intValue)
                    summary.job_num = stats["job_num"].intValue
                    summary.clear_num = stats["clear_num"].intValue
                    summary.dead_total = stats["dead_total"].intValue
                    summary.grade_point = stats["grade_point"].intValue
                    summary.help_total = stats["help_total"].intValue
                    summary.kuma_point_total = stats["kuma_point_total"].intValue
                    summary.my_ikura_total = stats["my_ikura_total"].intValue
                    summary.team_ikura_total = stats["team_ikura_total"].intValue
                    summary.my_golden_ikura_total = stats["my_golden_ikura_total"].intValue
                    summary.team_golden_ikura_total = stats["team_golden_ikura_total"].intValue
                    for (_, w) in stats["schedule"]["weapons"] {
                        summary.weapons.append(w["id"].intValue)
                    }
                    for (_, f) in stats["failure_counts"] {
                        summary.failure_count.append(f.intValue)
                    }
                    try? realm.write {
                        realm.add(summary, update: .modified)
                    }
                }
                
                // そこにバイト回数情報が載っているのでそれを利用（ネストがダサくなるが...
                let job_num = response["summary"]["card"]["job_num"].intValue
                // 最も新しいバイトIDをDBから取得する、なければ最新のものから49引いたものにする
                let latest_job_num = realm.objects(CoopResultsRealm.self).sorted(byKeyPath: "job_id", ascending: false).first?.job_id ?? max(0, job_num - 49)
                if job_num == latest_job_num { return } // 新規リザルトがなければ即戻る（もっと上手に書けんか？？？
                self.messages.append("Getting Results [\(latest_job_num)-\(job_num)]")
                for id in (latest_job_num ... job_num) {
                    self.messages.append("Getting Results \(id) [\(id - latest_job_num)/\(job_num - latest_job_num)]")
                    SplatNet2.getResultFromSplatNet2(job_id: id) { response in
                        let result = CoopResultsRealm()
                        // ここ、もっと上手い書き方できるので要リファクタリング
                        var players: [JSON] = []
                        players.append(response["my_result"])
                        for (_, other) in response["other_results"] {
                            players.append(other)
                        }
                        
                        // これ、全部なんかポイッと代入する関数つくったほうがいいのか？
                        result.nsaid = nsaid
                        result.job_id = response["job_id"].intValue
                        
                        // リージョンに依らずステージ名を共通化するコード（長い）
                        //guard let stage = Enum().Stage.filter({$0.url == response["schedule"]["stage"]["image"].stringValue.suffix(44)}).first?.name else { return }
                        result.stage_name = Stage(url: String(response["schedule"]["stage"]["image"].stringValue.suffix(44)))
                        result.danger_rate = response["danger_rate"].doubleValue
                        result.start_time = response["start_time"].intValue
                        result.play_time = response["play_time"].intValue
                        result.end_time = response["end_time"].intValue
                        result.grade_id = response["grade"]["id"].intValue
                        result.grade_point = response["grade_point"].intValue
                        result.grade_point_delta = response["grade_point_delta"].intValue
                        result.job_result_is_clear = response["job_result"]["is_clear"].boolValue
                        result.job_result_failure_reason = response["job_result"]["failure_reason"] == JSON.null ? nil :  response["job_result"]["failure_reason"].stringValue
                        result.job_result_failure_wave.value = response["job_result"]["failure_wave"] == JSON.null ? nil :  response["job_result"]["failure_wave"].intValue
                        for (_, boss) in response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }) {
                            result.appear.append(boss["count"].intValue)
                        }
                        for (_, w) in response["wave_details"] {
                            let wave = WaveDetailRealm()
                            wave.event_type = w["event_type"]["key"].stringValue == "water-levels" ? "-" : w["event_type"]["key"].stringValue
                            wave.water_level = w["water_level"]["key"].stringValue
                            wave.ikura_num = w["ikura_num"].intValue
                            wave.quota_num = w["quota_num"].intValue
                            wave.golden_ikura_num = w["golden_ikura_num"].intValue
                            wave.golden_ikura_pop_num = w["golden_ikura_pop_num"].intValue
                            wave.shift_id = result.start_time
                            result.power_eggs += wave.ikura_num
                            result.golden_eggs += wave.golden_ikura_num
                            result.wave.append(wave)
                        }
                        
                        // オオモノ討伐数を管理している（ダサいから直したい）
                        var defeat: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
                        for p in players {
                            let player = PlayerResultsRealm()
                            player.dead_count = p["dead_count"].intValue
                            player.help_count = p["help_count"].intValue
                            player.golden_ikura_num = p["golden_ikura_num"].intValue
                            player.ikura_num = p["ikura_num"].intValue
                            player.name = p["name"].stringValue
                            player.nsaid = p["pid"].stringValue
                            player.special_id = p["special"]["id"].intValue
                            for (_, sp) in p["special_counts"] {
                                player.special.append(sp.intValue)
                            }
                            for (_, wp) in p["weapon_list"] {
                                player.weapon.append(wp["id"].intValue)
                            }
                            for (i, (_, boss)) in p["boss_kill_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).enumerated() {
                                player.defeat.append(boss["count"].intValue)
                                defeat[i] += boss["count"].intValue
                            }
                            result.player.append(player)
                        }
                        for num in defeat { result.defeat.append(num) }
                        
                        // データベースに書き込み
                        try? realm.write {
                            realm.add(result, update: .modified)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Logging Thread")
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
