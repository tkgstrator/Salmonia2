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
        var statusCode: Int? = 200
        AF.request(url, method: .get)
//            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: queue) { response in
                switch response.result {
                case .success(let value):
                    statusCode = response.response?.statusCode
                    json = JSON(value)
                case .failure(let error):
                    print(error)
                }
                semaphore.signal()
            }
        semaphore.wait()
        
        guard let code: Int = statusCode else { throw APPError.unknown }
        guard let response: JSON = json else { throw APPError.unknown }
        
        if code == 403 { throw APPError.expired }
        return response
    }
}
