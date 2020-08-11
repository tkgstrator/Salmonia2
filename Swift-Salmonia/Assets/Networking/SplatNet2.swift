//
//  SplatNet2.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

private let semaphore = DispatchSemaphore(value: 0)
private let queue = DispatchQueue.global(qos: .utility)

class SplatNet2 {
    
    // メンバ変数を用意しておくけど、クラスを初期化せずに使えるのか？
    static private var nickname: String?
    static private var session_token: String?
    static private var thumbnail_url: String?
    
    static private let events: [Int: String] = [
        0: "-",
        1: "rush",
        2: "goldie-seeking",
        3: "griller",
        4: "the-mothership",
        5: "fog",
        6: "cohock-charge"
    ]
    
    static private let tides: [Int: String] = [
        0: "low",
        1: "normal",
        2: "high"
    ]
    
    class func getEventName(_ event_id: Int) -> String {
        return events[event_id]!
    }
    
    class func getWaterName(_ water_id: Int) -> String {
        return tides[water_id]!
    }
    
    class func getSessionToken(_ session_token_code: String, _ session_token_code_verifier: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/session_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "session_token_code": session_token_code,
            "session_token_code_verifier": session_token_code_verifier
        ]
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure:
                    break
                }
        }
    }
    
    class func getAccessToken(_ session_token: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/access_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "session_token": session_token
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure:
                    break
                }
        }
    }
    
    class func callFlapgAPI(_ access_token: String, _ type: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/login"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "access_token": access_token,
            "type": type
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure:
                    break
                }
        }
    }
    
    class func getSplatoonToken(_ result: JSON, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/splatoon_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        // ここもっと簡単に書けるだろ
        let body = [
            "f": result["f"].stringValue,
            "p1": result["p1"].stringValue,
            "p2": result["p2"].stringValue,
            "p3": result["p3"].stringValue
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    class func getSplatoonAccessToken(_ result: JSON, _ splatoon_token: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/splatoon_access_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        // ここもっと簡単に書けるだろ
        let body = [
            "parameter" : [
                "f": result["f"].stringValue,
                "p1": result["p1"].stringValue,
                "p2": result["p2"].stringValue,
                "p3": result["p3"].stringValue
            ],
            "splatoon_token": splatoon_token
            ] as [String : Any]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    class func getIksmSession(_ splatoon_access_token: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/iksm_session"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "splatoon_access_token": splatoon_access_token
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                    //                    iksm_session = JSON(value)["iksm_session"].stringValue
                    //                    nsaid = JSON(value)["nsaid"].stringValue
                    //                    SplatNet2.setUserInfoFromSplatNet2()
                //                    debugPrint("IKSM SESSION", iksm_session)
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    class func getResultFromSplatNet2(job_id: Int, complition: @escaping (JSON) -> ()) {
        guard let iksm_session: String = try? Realm().objects(UserInfoRealm.self).first?.iksm_session else { return }
        //        guard let api_token: String = realm.objects(UserInfoRealm.self).first?.api_token else { return }
        
        let url = "https://app.splatoon2.nintendo.net/api/coop_results/" + String(job_id)
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                    //                    uploadResultToSalmonStats(result: JSON(value), token: api_token)
                    break
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    class func uploadResultToSalmonStats(result: JSON, token: String) {
        let url = "https://salmon-stats-api.yuki.games/api/results"
        let header: HTTPHeaders = [
            "Content-type": "application/json",
            "Authorization": "Bearer " + token
        ]
        let body = ["results": [result.dictionaryObject]]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    class func getSummaryFromSplatNet2(completion: @escaping (JSON) -> ()) {
        guard let iksm_session: String = try? Realm().objects(UserInfoRealm.self).first?.iksm_session else { return }
        print("IKSM SESSION", iksm_session)
        
        let url = "https://app.splatoon2.nintendo.net/api/coop_results"
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    print("GET SUCCESS")
                    //                    print(JSON(value))
                    completion(JSON(value))
                case .failure:
                    print("REGENERATE")
                    //                    print(error)
                    SplatNet2.genIksmSession() { response in
                        //                        print(response)
                        completion(response)
                    }
                }
        }
    }
    
    class func genIksmSession(complition: @escaping (JSON) -> ()) {
        guard let session_token: String = try? Realm().objects(UserInfoRealm.self).first?.session_token else { return }
        
        SplatNet2.getAccessToken(session_token) { response in
            let access_token = response["access_token"].stringValue
            SplatNet2.callFlapgAPI(access_token, "nso") { response in
                SplatNet2.getSplatoonToken(response) { response in
                    let splatoon_token = response["splatoon_token"].stringValue
                    let nickname = response["user"]["name"].stringValue
                    let thumbnail_url = response["user"]["image"].stringValue
                    SplatNet2.callFlapgAPI(splatoon_token, "app") { response in
                        SplatNet2.getSplatoonAccessToken(response, splatoon_token) { response in
                            let splatoon_access_token = response["splatoon_access_token"].stringValue
                            SplatNet2.getIksmSession(splatoon_access_token) { response in
                                let iksm_session = response["iksm_session"].stringValue
                                let nsaid = response["nsaid"].stringValue
                                
                                print("IKSM SESSION", iksm_session)
                                autoreleasepool {
                                    guard let realm = try? Realm() else { return }
                                    try? realm.write {
                                        let user = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid)
                                        switch user.isEmpty {
                                        case true: // 新規作成
                                            print("CREATE NEW USER (LOGIN SPLATNET2)")
                                            let user: [String: String?] = ["nsaid": nsaid, "name": nickname, "image": thumbnail_url, "iksm_session": iksm_session, "session_token": session_token]
                                            realm.create(UserInfoRealm.self, value: user)
                                        case false: // 再ログイン（アップデート）
                                            print("USERINFO UPDATE (LOGIN SPLATNET2)")
                                            guard let session_token = user.first?.session_token else { return }
                                            user.setValue(iksm_session, forKey: "iksm_session")
                                            user.setValue(session_token, forKey: "session_token")
                                            user.setValue(thumbnail_url, forKey: "image")
                                            user.setValue(nickname, forKey: "name")
                                        }
                                    }
                                }
                                SplatNet2.getSummaryFromSplatNet2() { response in
                                    complition(response)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func getResultFromSplatNet2(_ iksm_session: String, _ job_id: Int) -> JSON {
        let url = "https://app.splatoon2.nintendo.net/api/coop_results/" + String(job_id)
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        var result: JSON = JSON()
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue ){ response in
                switch response.result {
                case .success(let value):
                    result = JSON(value)
                case .failure:
                    break
                }
                semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    class func getSummaryFromSplatNet2(_ iksm_session: String, completion: @escaping (JSON) -> ()) {
        let url = "https://app.splatoon2.nintendo.net/api/coop_results"
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        var summary: JSON = JSON()
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue){ response in
                switch response.result {
                case .success(let value):
                    summary = JSON(value)["summary"]
                    completion(summary)
                case .failure:
                    SplatNet2.genIksmSession() { response in
                        completion(response["summary"])
                    }
                }
        }
    }
    
    class func encodeResultFromJSON(nsaid: String, salmon_id: Int?, _ response: JSON) -> CoopResultsRealm {
        // 辞書型に変換
        var result: [String: Any?] = response.dictionaryObject!
        
        //書き込み用のWaveとPlayerの情報を保持
        var waves: [WaveDetailRealm] = []
        var players: [PlayerResultsRealm] = []
        
        for (_, data) in response["wave_details"] {
            var wave = data.dictionaryObject
            // この処理ダサいからもっとかっこよく書きたい
            wave?.updateValue(data["event_type"]["key"].stringValue == "water-levels" ? "-" : data["event_type"]["key"].stringValue, forKey: "event_type")
            wave?.updateValue(data["water_level"]["key"].stringValue, forKey: "water_level")
            wave?.updateValue(response["start_time"].intValue, forKey: "start_time")
            waves.append(WaveDetailRealm(value: wave as Any))
        }
        
        // これをなんとかしたい（切実
        var player_results: [JSON] = []
        player_results.append(response["my_result"])
        for (_, other) in response["other_results"] {
            player_results.append(other)
        }
        
        var player_kill_counts: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        for data in player_results {
            var player = data.dictionaryObject
            let boss_kill_counts: [Int] = data["boss_kill_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue })
            let weapon_list: [Int] = data["weapon_list"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["id"].intValue })
            player?.updateValue(data["special"]["id"].intValue, forKey: "special_id")
            player?.updateValue(data["pid"].stringValue, forKey: "nsaid")
            player?.updateValue(boss_kill_counts, forKey: "boss_kill_counts")
            player?.updateValue(weapon_list, forKey: "weapon_list")
            players.append(PlayerResultsRealm(value: player as Any))
            player_kill_counts = Array(zip(player_kill_counts, boss_kill_counts)).map({ $0.0 + $0.1 })
        }
        result.updateValue(salmon_id as Any, forKey: "salmon_id")
        result.updateValue(response["job_result"]["failure_wave"].int as Any, forKey: "failure_wave")
        result.updateValue(response["job_result"]["failure_reason"].string as Any, forKey: "failure_reason")
        result.updateValue(response["job_result"]["is_clear"].bool as Any, forKey: "is_clear")
        result.updateValue(waves.map({ $0.ikura_num }).reduce(0, +), forKey: "power_eggs")
        result.updateValue(waves.map({ $0.golden_ikura_num }).reduce(0, +), forKey: "golden_eggs")
        result.updateValue(nsaid, forKey: "nsaid")
        result.updateValue(ImageURL.stageid(String(response["schedule"]["stage"]["image"].stringValue.suffix(44))), forKey: "stage_id")
        result.updateValue(response["grade"]["id"].intValue, forKey: "grade_id")
        result.updateValue(response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue }), forKey: "boss_counts")
        result.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        
        // Wave情報とPlayer情報を追加する
        result.updateValue(waves, forKey: "wave")
        result.updateValue(players, forKey: "player")
        return CoopResultsRealm(value: result as Any)
    }
    
    //    class func genIksmSession(complition: @escaping (JSON) -> ()) {
    //        guard let realm = try? Realm() else { return }
    //        guard let session_token: String = realm.objects(UserInfoRealm.self).first?.session_token else { return }
    //        guard let user = realm.objects(UserInfoRealm.self).first else { return }
    //
    //        SplatNet2.getAccessToken(session_token: session_token) { response in
    //            let access_token = response["access_token"].stringValue
    //            SplatNet2.callFlapgAPI(access_token: access_token, type: "nso") { response in
    //                SplatNet2.getSplatoonToken(result: response) { response in
    //                    let splatoon_token = response["splatoon_token"].stringValue
    //                    let username = response["user"]["name"].stringValue
    //                    let imageUri = response["user"]["image"].stringValue
    //                    SplatNet2.callFlapgAPI(access_token: splatoon_token, type: "app") { response in
    //                        SplatNet2.getSplatoonAccessToken(result: response, splatoon_token: splatoon_token) { response in
    //                            let splatoon_access_token = response["splatoon_access_token"].stringValue
    //                            SplatNet2.getIksmSession(splatoon_access_token: splatoon_access_token) { response in
    //                                let iksm_session = response["iksm_session"].stringValue
    //                                try? realm.write {
    //                                    user.setValue(iksm_session, forKey: "iksm_session")
    //                                    user.setValue(username, forKey: "name")
    //                                    user.setValue(imageUri, forKey: "image")
    //                                }
    //                                SplatNet2.getSummaryFromSplatNet2() { response in
    //                                    complition(response)
    //                                }
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    class func getPlayerNickname(nsaid: String, complition: @escaping (JSON) -> ()) {
        guard let iksm_session: String = try? Realm().objects(UserInfoRealm.self).first?.iksm_session else { return }
        
        let url = "https://app.splatoon2.nintendo.net/api/nickname_and_icon?id=\(nsaid)"
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=\(iksm_session)"
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value))
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    class func getPlayerNickname(nsaid: [String], complition: @escaping (JSON?, Error?) -> ()) {
        guard let iksm_session: String = try? Realm().objects(UserInfoRealm.self).first?.iksm_session else { return }
        
        let query = nsaid.map({ "id=\($0)&" }).reduce("", +)
        let url = "https://app.splatoon2.nintendo.net/api/nickname_and_icon?\(query)"
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=\(iksm_session)"
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    complition(JSON(value)["nickname_and_icons"], nil)
                case .failure:
                    complition(nil, nil)
                }
        }
    }
}
