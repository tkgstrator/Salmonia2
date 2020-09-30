//
//  Alamofire.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import Foundation
import SwiftyJSON
import Alamofire

public class SAF {
    public class func request(_ url: String) throws -> JSON {
        
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue.global(qos: .utility)
        
        var json: JSON? = nil
        AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
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
        
        guard let response = json else { throw APIError.Response("9999", "Salmon Stats Error") }
        return response
    }
}
