//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-24.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON

struct LoadingView: View {
    @State var progress: Int = 0

    var body: some View {
        Text("Loading View")
        .onAppear() {
            // 表示されたときの任意の関数実行
            guard let realm = try? Realm() else { return }
            
            // 最初にサマリー情報を取得
            SplatNet2.getSummaryFromSplatNet2() { response in
                guard let nsaid = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
                for (_, stats) in response["summary"]["stats"] {
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
                    do {
                        try realm.write {
                            realm.add(summary, update: .modified)
                        }
                    } catch(let error) {
                        print(error)
                    }
                }
                
                // そこにバイト回数情報が載っているのでそれを利用（ネストがダサくなるが...
                let job_num = response["summary"]["card"]["job_num"].intValue
                // 最も新しいバイトIDをDBから取得する、なければ最新のものから49引いたものにする
                let latest_job_num = realm.objects(CoopResultsRealm.self).sorted(byKeyPath: "start_time", ascending: false).first?.job_id ?? max(0, job_num - 49)
                for id in (latest_job_num ... job_num) {
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
                        guard let stage = Enum().Stage.filter({$0.url == response["schedule"]["stage"]["image"].stringValue.suffix(44)}).first?.name else { return }
                        result.stage_name = stage
                        result.danger_rate = response["danger_rate"].doubleValue
                        result.start_time = response["start_time"].intValue
                        result.play_time = response["play_time"].intValue
                        result.end_time = response["end_time"].intValue
                        result.grade_id = response["grade"]["id"].intValue
                        result.grade_point = response["grade_point"].intValue
                        result.grade_point_delta = response["grade_point_delta"].intValue
                        result.job_result_is_clear = response["job_result"]["is_clear"].stringValue == "true"
                        result.job_result_failure_reason = response["job_result"]["failure_reason"].stringValue
                        result.job_result_failure_wave.value = response["job_result"]["failure_wave"].intValue
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
                            realm.add(result, update: .all)
                        }
                    }
                }
            }
        }
    }
    
}

