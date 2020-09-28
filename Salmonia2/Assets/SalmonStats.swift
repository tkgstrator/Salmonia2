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
import WebKit

class SalmonStats {
    
    class func getAPIToken(_ laravel_session: String) throws -> String {
        let apitoken: JSON = try SalmonStats.get(laravel_session: laravel_session)
        return apitoken["api_token"].stringValue
    }

    class func getPlayerOverView(nsaid: String, completion: @escaping (JSON) -> ()) {
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        
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
