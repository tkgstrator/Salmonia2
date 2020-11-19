//
//  OtherPlayerView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import RealmSwift
import URLImage
import Combine

struct OtherPlayerView: View {
    @EnvironmentObject var player: CrewInfoCore
    
    var body: some View {
        ScrollView {
            HStack {
//                NavigationLink(destination: ResultCollectionView().environmentObject(UserResultCore())) {
                URLImage(url: URL(string: player.imageUri ?? "https://cdn-image-e0d67c509fb203858ebcb2fe3f88c2aa.baas.nintendo.com/1/c9714d21f0dce5c6")!) { image in
                    image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))}
                    .frame(width: 80, height: 80)
//                }.buttonStyle(PlainButtonStyle())
                Text(player.nickname).modifier(Splatfont(size: 28)).frame(maxWidth: .infinity)
            }
            Text("Overview").foregroundColor(.cOrange).modifier(Splatfont(size: 20))
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Jobs")
                    Text("\(player.job_num)")
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Avg Eggs")
                    HStack {
                        Text(String((Double(player.golden_ikura_total) / Double(player.job_num)).round(digit: 2))).foregroundColor(.yellow)
                        Text("/")
                        Text(String((Double(player.ikura_total) / Double(player.job_num)).round(digit: 2))).foregroundColor(.red)
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("Defeated")
                    HStack {
                        Text(String((Double(player.defeated) / Double(player.job_num)).round(digit: 2)))
                    }
                }
                Spacer()
            }.modifier(Splatfont(size: 18))
        }
        .onAppear() {
            guard let realm = try? Realm() else { return }
            guard let user = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", player.nsaid).first else { return }
            let current_time: Int = Int(Date().timeIntervalSince1970)
            if current_time >= user.lastUpdated + 3600 * 24 && player.job_num >= 30 {
                // 先にタイムスタンプを書き込んでおけば再読み込みのリロードを防げる
                realm.beginWrite()
                user.lastUpdated = current_time
                try? realm.commitWrite()
                getPlayerSRPower(nsaid: player.nsaid) { srpower in
                    realm.beginWrite()
                    user.srpower.value = srpower
                    user.lastUpdated = current_time
                    try? realm.commitWrite()
                }
            }
        }
        .padding(.horizontal, 10)
        .navigationBarTitle(player.nickname)
        .navigationBarItems(trailing: favButton)
    }
    
    private func getPlayerSRPower(nsaid: String, completion: @escaping (Double?) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=30&page=1"
        
        AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let results: [JSON] = JSON(value)["results"].reversed().map({ $0.1 })
                    completion(SRPower(results))
                case .failure:
                    break
                }
            }
            
        }
    
    private func SRPower(_ results: [JSON]) -> Double? {
        if results.count < 30 { return nil }
        
        let bossrate: [Int] = [1783, 1609, 2649, 1587, 1534, 1563, 1500, 1783, 2042]
        var ilorate: Double? = nil
        var tmprate: Double = 0.0
        
        let win_count: Int = results.prefix(10).filter({$0["clear_waves"].intValue == 3}).count

        for (idx, result) in results.enumerated() {
            let isClear = result["clear_waves"].intValue == 3
            let _player = result["player_results"].filter({ $0.1["player_id"].stringValue == player.nsaid }).map({ $0.1 }).first!
            let bias = CalcBias(result)
            let baserate: Int = (Array(zip(bossrate, _player["boss_eliminations"]["counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1.intValue }))).map({$0 * $1}).reduce(0, +)) / max(1, _player["boss_elimination_count"].intValue)
            let salmonrate: Double = min(bias * Double(baserate), 3074.5).round(digit: 2)

            switch idx {
            case (0...9):
                tmprate += salmonrate
                if idx == 9 {
                    tmprate = (tmprate / 10).round(digit: 2)
                    switch win_count {
                    case 0:
                        ilorate = tmprate - 400
                    case 10:
                        ilorate = tmprate + 400
                    default:
                        ilorate = (tmprate + 400 * log10(Double(win_count)/Double(10 - win_count))).round(digit: 2)
                    }
                }
            default:
                let delta: Double = isClear ? min((32 / (pow(10, ((ilorate ?? 0.0) - salmonrate) / 400) + 1)), 32.0) : max(-1 * 32 / (pow(10, (salmonrate - (ilorate ?? 0.0)) / 400) + 1), -32.0)
                ilorate = ((ilorate ?? 0.0) + delta).round(digit: 2)
            }
        }
        return ilorate
    }

    private func CalcBias(_ result: JSON) -> Double {
        let danger_rate: Double = result["danger_rate"].doubleValue
        let rate: Double = (Double(min(danger_rate * 3, 600)) / 5.0 + 80) / 160.0
        let max_bias: Double = danger_rate == 200 ? 1.5 : 1.25
        var bias: (defeated: Double, golden: Double) = (0.0, 0.0)
        
        let _player = result["player_results"].filter({ $0.1["player_id"].stringValue == player.nsaid }).map({ $0.1 }).first!
        let quota_num = result["waves"].map({ $0.1["golden_egg_quota"].intValue }).reduce(0, +)
        let defeated_num = _player["boss_elimination_count"].intValue
        let appear_num = result["boss_appearance_count"].intValue
        
        let golden_ikura_num = _player["golden_eggs"].intValue
        if (golden_ikura_num * 4 >= quota_num && defeated_num * 4 >= appear_num && defeated_num > 0) {
            bias.defeated = min(Double(defeated_num * 99) / Double(17 * defeated_num), max_bias)
        }

        if (golden_ikura_num * 3 >= quota_num && defeated_num * 5 >= appear_num) {
            bias.golden = min(rate + Double(10 * (golden_ikura_num * 3 - quota_num)) / (9.0 * 160.0), max_bias)
        }
        return max(bias.defeated, bias.golden, rate)
    }

    private var favButton: some View {
        switch player.isFav {
        case true:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "bookmark.fill").resizable().aspectRatio(contentMode: .fit).frame(height: 20) })
        case false:
            return AnyView(Button(action: { onToggleFav() }) { Image(systemName: "bookmark.fill").resizable().aspectRatio(contentMode: .fit).frame(height: 20).foregroundColor(.gray) })
        }
    }
    
    private func onToggleFav() {
        guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
        guard let player = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", player.nsaid).first else { return }
        let favuser = user.favuser.filter("nsaid=%@", player.nsaid)
        
        try! realm.write {
            player.isFav.toggle()
            switch favuser.isEmpty {
            case true:
                user.favuser.append(player)
            case false:
                guard let index = user.favuser.index(of: player) else { return }
                user.favuser.remove(at: index)
            }
        }
    }
}

//struct OtherPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        OtherPlayerView(player: <#Environment<CrewInfoCore>#>)
////        OtherPlayerView(nsaid: nil)
//    }
//}
