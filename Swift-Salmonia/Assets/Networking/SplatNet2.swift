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

class SplatNet2 {
    class func getSessionToken(session_token_code: String, session_token_code_verifier: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/session_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "session_token_code": session_token_code,
            "session_token_code_verifier": session_token_code_verifier
        ]
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
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
    
    class func getAccessToken(session_token: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/access_token"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "session_token": session_token
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
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
    
    class func callFlapgAPI(access_token: String, type: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/login"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "access_token": access_token,
            "type": type
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
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
    
    class func getSplatoonToken(result: JSON, complition: @escaping (JSON) -> ()) {
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
    
    class func getSplatoonAccessToken(result: JSON, splatoon_token: String, complition: @escaping (JSON) -> ()) {
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
    
    class func getIksmSession(splatoon_access_token: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmonia.mydns.jp/api/iksm_session"
        let header: HTTPHeaders = [
            "User-Agent": "Salmonia iOS"
        ]
        let body = [
            "splatoon_access_token": splatoon_access_token
        ]
        
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
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
    
//    class func getResultFromSplatNet2(job_id: Int, complition: @escaping (CoopResultsRealm) -> ()) {
//        guard let realm = try? Realm() else { return }
//        guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
//
//        let url = "https://app.splatoon2.nintendo.net/api/coop_results/" + String(job_id)
//        let header: HTTPHeaders = [
//            "cookie" : "iksm_session=" + iksm_session
//        ]
//
//        AF.request(url, method: .get, headers: header)
//            .validate(contentType: ["application/json"])
//            .responseJSON{ response in
//                switch response.result {
//                case .success(let value):
//                    let response = JSON(value)
//                    let result = CoopResultsRealm()
//
//
//                    //                    uploadResultToSalmonStats(result: JSON(value), token: api_token)
//                    break
//                case .failure(let error):
//                    print(error)
//                }
//        }
//    }
    
    class func getResultFromSplatNet2(iksm_session: String, job_id: Int, completion: @escaping (JSON?, Error?) -> ()) {
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
                    completion(JSON(value), nil)
                case .failure:
                    completion(nil, APPError.Response(id: 2000, message: "iksm_session is expired"))
                }
        }

    }
    
    class func getSummaryFromSplatNet2(iksm_session: String, completion: @escaping (JSON?, Error?) -> ()) {
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
                    completion(JSON(value)["summary"], nil)
                case .failure:
                    completion(nil, APPError.Response(id: 2000, message: "SplatNet2 Server Error"))
                }
        }
    }
    
    class func encodeResultToSplatNet2(response: JSON, nsaid: String) -> CoopResultsRealm {
        // 辞書型に変換
        var result = response.dictionaryObject
        
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
        result?.updateValue(response["job_result"]["failure_wave"].int as Any, forKey: "failure_wave")
        result?.updateValue(response["job_result"]["failure_reason"].string as Any, forKey: "failure_reason")
        result?.updateValue(response["job_result"]["is_clear"].bool as Any, forKey: "is_clear")
        result?.updateValue(waves.map({ $0.ikura_num }).reduce(0, +), forKey: "power_eggs")
        result?.updateValue(waves.map({ $0.golden_ikura_num }).reduce(0, +), forKey: "golden_eggs")
        result?.updateValue(nsaid, forKey: "nsaid")
        result?.updateValue(Stage(url: String(response["schedule"]["stage"]["image"].stringValue.suffix(44))), forKey: "stage_name")
        result?.updateValue(response["grade"]["id"].intValue, forKey: "grade_id")
        result?.updateValue(response["boss_counts"].sorted(by: { Int($0.0)! < Int($1.0)! }).map({ $0.1["count"].intValue }), forKey: "boss_counts")
        result?.updateValue(player_kill_counts, forKey: "boss_kill_counts")
        
        // Wave情報とPlayer情報を追加する
        result?.updateValue(waves, forKey: "wave")
        result?.updateValue(players, forKey: "player")
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
        
        let url = "https://app.splatoon2.nintendo.net/api/nickname_and_icon?id=" + nsaid
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        AF.request(url, method: .get, headers: header).responseJSON { response in
            switch response.result {
            case .success(let value):
                complition(JSON(value))
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}
