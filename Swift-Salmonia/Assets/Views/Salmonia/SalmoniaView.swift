//
//  SalmoniaView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import Combine
import URLImage

class UserInfoModel: ObservableObject {
    private var infoToken: NotificationToken?
    private var resultToken: NotificationToken?
//    public let result = try? Realm().objects(CoopResultsRealm.self) // 監視対象
//    public let info = try? Realm().objects(UserInfoRealm.self) // 監視対象

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

struct UserInformationView: View {
    private var name: String
    private var image: String
    
    init(user: UserInformation){
        name = user.username ?? "-"
        image = user.imageUri ?? "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/1e2bdb741756efcf"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: ResultsCollectionView()) {
                URLImage(URL(string: image)!, content:  {$0.image.renderingMode(.original).resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}).frame(width: 80, height: 80)
            }
            Spacer()
            Text(name).font(.custom("Splatfont2", size: 30)).frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
}

struct SalmoniaView: View {
    @ObservedObject var users = UserInfoModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    UserInformationView(user: users.information)
                    PlayerOverView(data: users.information)
                }
            }
            .padding(.horizontal, 10)
            .navigationBarTitle(Text("Salmonia"))
            .navigationBarItems(leading:
                NavigationLink(destination: SettingsView(user: users.information))
                {
                    Image(systemName: "gear").resizable().scaledToFit().frame(width: 30, height: 30)
                }, trailing:
                NavigationLink(destination: LoadingView())
                {
                    Image(systemName: "arrow.clockwise.icloud").resizable().scaledToFit().frame(width: 30, height: 30)
                }
            )
        }
    }
}


struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
