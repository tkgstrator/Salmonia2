//
//  UnixTime.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-23.
//

import Foundation

public class UnixTime {
    public class func dateFromTimestamp(_ interval: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(interval)))
    }
    
//    public class func timestampFromSalmonStats(_ interval: Int) ->
}
