//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-24.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift

struct LoadingView: View {
    @State var progress: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Progress \(progress)")
            .onReceive(timer) { time in
                self.progress += 1
        }
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
                let latest_job_num = realm.objects(CoopResultsRealm.self).first?.job_id ?? max(0, job_num - 49)
                for id in (latest_job_num ... job_num) {
                    SplatNet2.getResultFromSplatNet2(job_id: id)
                    //                            sleep(1)
                    // メインの描画を変える処理はここで書く
                }
            }
        }
    }
    
}

