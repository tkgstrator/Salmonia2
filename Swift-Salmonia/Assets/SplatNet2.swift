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

class SplatNet2 {
    
    static var session_token: String = ""
    static var access_token: String = ""
    static var splatoon_token: String = ""
    static var splatoon_access_token: String = ""
    static var iksm_session: String = ""
    static var nsaid: String = ""
    static var user: (name: String, image: String) = (name: "", image: "")
    static let realm = try! Realm() // 多分存在するやろ

    class func getSessionToken(session_token_code: String, session_token_code_verifier: String) {
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
                    session_token = JSON(value)["session_token"].stringValue
                    debugPrint("SESSION TOKEN", session_token)
                    SplatNet2.getAccessToken(session_token: session_token)
                case .failure:
                    break
                }
        }
    }
    
    class func getAccessToken(session_token: String) {
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
                    access_token = JSON(value)["access_token"].stringValue
                    debugPrint("ACCESS TOKEN", access_token)
                    SplatNet2.callFlapgAPI(access_token: access_token, type: "nso")
                case .failure:
                    break
                }
        }
    }
    
    class func callFlapgAPI(access_token: String, type: String) {
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
                    let body = JSON(value)
                    switch type {
                    case "app":
                        debugPrint("FLAPG API(APP)", value)
                        SplatNet2.getSplatoonAccessToken(result: body, splatoon_token: splatoon_token)
                    case "nso":
                        debugPrint("FLAPG API(NSO)", value)
                        SplatNet2.getSplatoonToken(result: body)
                    default:
                        break
                    }
                case .failure:
                    break
                }
        }
    }
    
    class func getSplatoonToken(result: JSON) {
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
                    splatoon_token = JSON(value)["splatoon_token"].stringValue
                    user = (name: JSON(value)["user"]["name"].stringValue, image: JSON(value)["user"]["image"].stringValue)
                    debugPrint("SPLATOON TOKEN", splatoon_token)
                    SplatNet2.callFlapgAPI(access_token: splatoon_token, type: "app")
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    class func getSplatoonAccessToken(result: JSON, splatoon_token: String) {
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
                    splatoon_access_token = JSON(value)["splatoon_access_token"].stringValue
                    debugPrint("SPLATOON ACCESS TOKEN", splatoon_access_token)
                    SplatNet2.getIksmSession(splatoon_access_token: splatoon_access_token)
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    class func getIksmSession(splatoon_access_token: String) {
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
                    iksm_session = JSON(value)["iksm_session"].stringValue
                    nsaid = JSON(value)["nsaid"].stringValue
                    SplatNet2.setUserInfoFromSplatNet2()
                    debugPrint("IKSM SESSION", iksm_session)
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
        
    }
    
    class func setUserInfoFromSplatNet2() {
        let userinfo = UserInfoRealm()
        
        userinfo.name = user.name
        userinfo.image = user.image
        userinfo.iksm_session = iksm_session
        userinfo.session_token = session_token
        userinfo.nsaid = nsaid
        
        do {
            try realm.write {
                realm.add(userinfo, update: .all)
            }
        } catch {
            debugPrint("Realm Write Error")
        }
        debugPrint("Write New Record")
    }
    
    class func getResultFromSplatNet2(job_id: Int, completion: (JSON) -> ()) {
        let url = "https://app.splatoon2.nintendo.net/api/coop_results/" + String(job_id)
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        var json: JSON = JSON()
        
        AF.request(url, method: .get, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    json = JSON(value)
                    print(json)
                case .failure(let error):
                    print(error)
                }
        }
        completion(json)
    }
    
    class func getSummaryFromSplatNet2(completion: @escaping (JSON) -> ()) {
        guard let iksm_session: String = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
        let url = "https://app.splatoon2.nintendo.net/api/coop_results"
        let header: HTTPHeaders = [
            "cookie" : "iksm_session=" + iksm_session
        ]
        
        AF.request(url, method: .get, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value))
                case .failure(let error):
                    print(error)
                }
        }
    }
}
