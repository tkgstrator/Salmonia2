//
//  SalmonStats.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//
import Foundation
import Alamofire
import SwiftyJSON
import Foundation
import RealmSwift
import WebKit

class SalmonStats {
    
    class func getAPIToken(_ laravel_session: String) throws -> String {
        let apitoken: JSON = try SalmonStats.get(laravel_session: laravel_session)
        return apitoken["api_token"].stringValue
    }
    
    //    class func getPlayerOverView(nsaid: String) -> PlayerInfo {
    //        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
    //
    //        let json: JSON = try! SAF.request(url)
    //        let result = json[0]["results"]
    //        let total = json[0]["total"]
    //
    //        var player = PlayerInfo()
    //        player.nsaid = nsaid
    //        player.job_num = result["clear"].intValue + result["fail"].intValue
    //        player.ikura_total = total["power_eggs"].intValue
    //        player.golden_ikura_total = total["golden_eggs"].intValue
    //        return player
    //    }
    
    class func getPlayerOverView(nsaid: String) {
        guard let realm = try? Realm() else { return }
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        
        AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let result = json[0]["results"]
                    let total = json[0]["total"]
                    
                    let player = CrewInfoRealm()
                    player.nsaid = nsaid
                    player.job_num = result["clear"].intValue + result["fail"].intValue
                    player.ikura_total = total["power_eggs"].intValue
                    player.golden_ikura_total = total["golden_eggs"].intValue
                    
                    try! realm.write {
                        realm.create(CrewInfoRealm.self, value: player, update: .modified)
                    }
                case .failure:
                    break
                }
            }
    }
    
    class func getPlayerShiftStats(nsaid: String, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/schedules"
        
        AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(JSON(value))
                case .failure:
                    break
                }
            }
    }
    
    class func uploadSalmonStats(token: String, _ results: [Dictionary<String, Any>]) -> JSON {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .utility)
        
        let url = "https://salmon-stats-api.yuki.games/api/results"
        let header: HTTPHeaders = [
            "Content-type": "application/json",
            "Authorization": "Bearer " + token
        ]
        let body = ["results": results]
        
        var salmon_ids: JSON = JSON()
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    salmon_ids = JSON(value)
                case .failure(let error):
                    print(error)
                }
                semaphore.signal()
            }
        semaphore.wait()
        return salmon_ids
    }
    
    private class func get(laravel_session: String) throws -> JSON {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .utility)
        
        let url = "https://salmon-stats-api.yuki.games/api-token"
        let header: HTTPHeaders = [
            "Cookie" : "laravel_session=\(laravel_session)"
        ]
        
        var json: JSON? = nil
        AF.request(url, method: .get, headers: header)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    json = JSON(value)
                case .failure(let error):
                    print(error)
                }
                semaphore.signal()
            }
        semaphore.wait()
        
        guard let response = json else { throw APIError.Response("9404", "Server Error") }
        return response
    }
    
}
