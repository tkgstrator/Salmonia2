//
//  SalmonStats.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import WebKit

class SalmonStats {
    
    static let realm = try! Realm() // 多分存在するやろ
    
    // プレイヤーの戦績一覧を取得
    class func getPlayerOverView(nsaid: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=" + nsaid
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                complition(JSON(value))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // プレイヤーの最新のリザルト10件の概要を取得
    class func getPlayerOverViewResults(nsaid: String, complition: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/" + nsaid
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                complition(JSON(value)["results"])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // エラーコード1001を返す
    class func loginSalmonStats(complition: @escaping (Error?) -> ()) {
        WKWebView().configuration.websiteDataStore.httpCookieStore.getAllCookies {
            cookies in
            for cookie in cookies {
                if cookie.name == "laravel_session" {
                    let laravel_session = cookie.value
                    getTokenFromSalmonStats(session_token: laravel_session) { response, error in
                        guard let token = response?["api_token"].stringValue else {
                            complition(APPError.Response(id: 1001, message: "Login Salmon Statsr"))
                            return }
                        guard let user = realm.objects(UserInfoRealm.self).first else { return }
                        // データベース書き込み
                        do {
                            try realm.write { user.setValue(token, forKey: "api_token") }
                        } catch {
                            complition(APPError.Database(id: 1001, message: "Realm write error"))
                        }
                    }
                }
            }
        }
    }
    
    // エラーコード1000を返す
       class func getTokenFromSalmonStats(session_token: String, completion: @escaping  (JSON?, Error?) -> ()) {
           let url = "https://salmon-stats-api.yuki.games/api-token"
           let header: HTTPHeaders = [
               "Cookie" : "laravel_session=" + session_token
           ]
           
           AF.request(url, method: .get, headers: header)
               .validate(contentType: ["application/json"])
               .responseJSON { response in
                   switch response.result {
                   case .success(let value):
                       completion(JSON(value), nil)
                   case .failure:
                       // レスポンスがおかしいことを示した上でリターン
                       completion(nil, APPError.Response(id: 1000, message: "Server Error"))
                   }
           }
       }
}
