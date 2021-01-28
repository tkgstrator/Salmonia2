//
//  UnixTime.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-23.
//

import Foundation
import RealmSwift

public class UnixTime {
    
    public class func dateFromTimestamp(_ timestamp: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    public class func timestampFromDate(date: String) -> Int {
        let f = DateFormatter()
        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return Int((f.date(from: date) ?? Date()).timeIntervalSince1970)
    }
    
    public class func dateToStartTime(_ start_time: Int) -> String {
        let f = DateFormatter()
        f.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        f.dateFormat = "yyyyMMddHH"
        return f.string(from: Date(timeIntervalSince1970: Double(start_time)))
    }

}

