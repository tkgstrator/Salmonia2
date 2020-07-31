//
//  SettingsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON

// 設定画面を表示するビュー
struct SettingsView: View {
    private let url = "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form"
    
    @ObservedObject var user = UserInfoModel()
    @State private var isVisible: Bool = false
    
    private var iksm_session: String?
    private var session_token: String?
    private var api_token: String?
    
    init(){
//        iksm_session = user.iksm_session
//        session_token = user.session_token
//        api_token = user.api_token
    }
    
    var body: some View {
        List {
            Section(header: Text("Login")) {
                Button(action: {
                    UIApplication.shared.open(URL(string: self.url)!)
                }) {
                    HStack {
                        Text("SplatNet2")
                        Spacer()
                        Image(systemName: "safari").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }
                Button(action: {
                    SplatNet2.loginSalmonStats()
                }) {
                    HStack {
                        Text("Salmon Stats")
                        Spacer()
                        Image(systemName: "snow").resizable().foregroundColor(Color.blue).scaledToFit().frame(width: 25, height: 25)
                    }
                }
            }
            Section(header: Text("UserInfo")) {
                SettingColumn(title: "iksm_session", value: iksm_session)
                SettingColumn(title: "session_token", value: session_token)
                SettingColumn(title: "api_token", value: api_token)
            }
        }
        .listStyle(DefaultListStyle())
        .navigationBarTitle(Text("Settings"))
        .tag("Settings")
        .navigationBarItems(trailing:
            Button(action: {
                guard let realm = try? Realm() else { return }
                guard let nsaid = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
                
                SplatNet2.importResultsFromSalmonStats() { response in
                    print("IN COMPLITION", Int(Date().timeIntervalSince1970), response["id"].intValue)
                    // ここに書き込み処理書いてもいいけど、ダサくね？
                    // SplatNet2用のコードをSalmon Stats向けに書き直す
                    let result = CoopResultsRealm()
                    // ここ、もっと上手い書き方できるので要リファクタリング
                    let players = response["player_results"]
                    
                    // これ、全部なんかポイッと代入する関数つくったほうがいいのか？
                    result.nsaid = nsaid
                    result.job_id = -1 // Salmon Statsはjob_idを保存していないのでプレースホルダとして-1を代入
                    // リージョンに依らずステージ名を共通化するコード（長い）
                    result.stage_name = Enum().Stage[response["schedule"]["stage_id"].intValue - 1].name
                    result.danger_rate = response["danger_rate"].doubleValue // OK
                    
                    result.start_time = response["schedule"]["schedule_id"].stringValue.unixtime // OK?
                    let play_time = response["start_at"].stringValue.unixtime
                    result.play_time = play_time
                    result.end_time = response["schedule"]["end_at"].stringValue.unixtime
                    result.grade_id = -1 // なさそうな気がするのでやはりプレースホルダを代入
                    result.grade_point = -1 // なさそうな気がするのでやはりプレースホルダを代入
                    result.grade_point_delta = -1 // なさそうな気がするのでやはりプレースホルダを代入
                    result.job_result_is_clear = response["clear_waves"].intValue == 3 // OK?
                    result.job_result_failure_reason = response["fail_reason_id"].intValue.reasonid // OK?
                    result.job_result_failure_wave.value = response["clear_waves"].intValue == 3 ? nil : response["clear_waves"].intValue + 1 //OK?
                    // Salmon Statsは別枠で保存しているのでこれが利用できる
                    result.power_eggs = response["power_egg_collected"].intValue
                    result.golden_eggs = response["golden_egg_delivered"].intValue
                    for (_, boss) in response["boss_appearances"].sorted(by: { Int($0.0)! < Int($1.0)! }) {
                        result.appear.append(boss.intValue) // OK?
                    }
                    for (_, w) in response["waves"] {
                        let wave = WaveDetailRealm()
                        wave.event_type = w["event_id"].intValue.eventid // OK
                        wave.water_level = w["water_id"].intValue.waterid // OK
                        wave.ikura_num = w["power_egg_collected"].intValue // OK
                        wave.quota_num = w["golden_egg_quota"].intValue // OK
                        wave.golden_ikura_num = w["golden_egg_delivered"].intValue // OK
                        wave.golden_ikura_pop_num = w["golden_egg_appearances"].intValue // OK
                        wave.shift_id = result.start_time //
                        result.wave.append(wave)
                    }
                    
                    // オオモノ討伐数を管理している（ダサいから直したい）
                    var defeat: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
                    for (i, (_, p)) in players.enumerated() {
                        let player = PlayerResultsRealm()
                        player.dead_count = p["death"].intValue // OK?
                        player.help_count = p["rescue"].intValue // OK?
                        player.golden_ikura_num = p["golden_eggs"].intValue // OK?
                        player.ikura_num = p["power_eggs"].intValue // OK?
                        player.name = response["member_accounts"][i]["name"].stringValue // NG?
                        player.nsaid = p["player_id"].stringValue // OK
                        player.special_id = p["special_id"].intValue // OK
                        for (_, sp) in p["special_uses"] {
                            player.special.append(sp["count"].intValue)
                        }
                        for (_, wp) in p["weapons"] {
                            player.weapon.append(wp["weapon_id"].intValue)
                        }
                        for (i, (_, boss)) in p["boss_eliminations"]["counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).enumerated() {
                            player.defeat.append(boss.intValue)
                            defeat[i] += boss.intValue
                        }
                        result.player.append(player)
                    }
                    for num in defeat { result.defeat.append(num) }
                    
                    // 同じリザルトがないかチェックする
                    let isValid: Bool  = realm.objects(CoopResultsRealm.self).filter("play_time <= %@ and play_time >= %@ and job_id != -1", play_time + 10, play_time - 10).count == 0
//                    print("ISVALID", isValid)
                    if isValid {
                        try? realm.write {
                            realm.add(result, update: .all)
                        }
                    }
                }
            }) {
                Image(systemName: "square.and.arrow.down").resizable().scaledToFit().frame(width: 30, height: 30).foregroundColor(Color.blue)
            }.disabled(true)
        )
    }
}

struct SettingColumn: View {
    var title: String
    var value: String
    
    init(title: String, value: String?) {
        self.title = title
        self.value = value != nil ? "Registered" : "Unregistered"
    }
    
    var body: some View {
        HStack {
            Text(self.title)
            Spacer()
            Text(self.value).foregroundColor(Color.gray)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
