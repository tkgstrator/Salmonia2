//
//  SplatNet2.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-21.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import WebKit

class SplatNet2 {
    
    static let realm = try! Realm() // 多分存在するやろ
    
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
    
    class func getResultFromSplatNet2(job_id: Int, complition: @escaping (JSON) -> ()) {
        guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
        guard let api_token: String = realm.objects(UserInfoRealm.self).first?.api_token else { return }
        
        let url = "https://app.splatoon2.nintendo.net/api/coop_results/" + String(job_id)
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        AF.request(url, method: .get, headers: header)
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
        guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
        
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
                    completion(JSON(value))
                case .failure(let error):
                    print("REGENERATE")
                    print(error)
                    SplatNet2.genIksmSession() { response in
                        completion(response)
                    }
                }
        }
    }
    
    class func genIksmSession(complition: @escaping (JSON) -> ()) {
        guard let session_token: String = realm.objects(UserInfoRealm.self).first?.session_token else { return }
        guard let user = realm.objects(UserInfoRealm.self).first else { return }
        
        SplatNet2.getAccessToken(session_token: session_token) { response in
            let access_token = response["access_token"].stringValue
            SplatNet2.callFlapgAPI(access_token: access_token, type: "nso") { response in
                SplatNet2.getSplatoonToken(result: response) { response in
                    let splatoon_token = response["splatoon_token"].stringValue
                    let username = response["user"]["name"].stringValue
                    let imageUri = response["user"]["image"].stringValue
                    SplatNet2.callFlapgAPI(access_token: splatoon_token, type: "app") { response in
                        SplatNet2.getSplatoonAccessToken(result: response, splatoon_token: splatoon_token) { response in
                            let splatoon_access_token = response["splatoon_access_token"].stringValue
                            SplatNet2.getIksmSession(splatoon_access_token: splatoon_access_token) { response in
                                let iksm_session = response["iksm_session"].stringValue
                                try? realm.write {
                                    user.setValue(iksm_session, forKey: "iksm_session")
                                    user.setValue(username, forKey: "name")
                                    user.setValue(imageUri, forKey: "image")
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
    
    class func getTokenFromSalmonStats(session_token: String, completion: @escaping (JSON?) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api-token"
        let header: HTTPHeaders = [
            "Cookie" : "laravel_session=" + session_token
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value))
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    class func loginSalmonStats() {
        WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
            cookies in
            for cookie in cookies {
                if cookie.name == "laravel_session" {
                    let laravel_session = cookie.value
                    getTokenFromSalmonStats(session_token: laravel_session) {
                        response in
                        guard let token = response?["api_token"].stringValue else { return }
                        print("API TOKEN",token)
                        guard let user = realm.objects(UserInfoRealm.self).first else { return }
                        do {
                            try realm.write {
                                user.setValue(token, forKey: "api_token")
                            }
                        } catch { }
                    }
                }
            }
        }
    }
    
    // 取得すべきリザルトのIDを返す関数
    class func getIDFromSalmonStats(completion: @escaping (JSON) -> ()) {
        guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results"
        AF.request(url, method: .get)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value))
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    // 呼び出すとnsaidからSalmon Statsの全記録を取得して返す
    class func importResultsFromSalmonStats(complition: @escaping (JSON) -> ()) {
        guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
        
        SplatNet2.getIDFromSalmonStats() { response in
            let pages = response["last_page"].intValue
            for page in (20 ... 20) {
                let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?page=\(page)"
                AF.request(url, method: .get)
                    .validate(contentType: ["application/json"])
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let results = JSON(value)["data"]
                            for data in (0 ..< 3) {
                                print("ID", results[data]["id"].intValue)
                                SplatNet2.getResultFromSalmonStats(id: results[data]["id"].intValue) { response in
                                    complition(response)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                }
            }
        }
    }
    
    // リザルト自体のJSONを返す関数
    class func getResultFromSalmonStats(id: Int, complition: @escaping (JSON) -> ()) {
        print("GET RESULT", Int(Date().timeIntervalSince1970), id)
        let url = "https://salmon-stats-api.yuki.games/api/results/\(id)"
        
        AF.request(url, method: .get)
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
}
