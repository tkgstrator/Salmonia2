//
//  Extension.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftUI

extension ResultView {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // locate far out of screen
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        controller.view.backgroundColor = .clear
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
    
    func takeScreenShot(origin: CGPoint, size: CGSize) -> UIImage {
        let screen = ResultView(data: self.result)
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: screen)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.asImage()
    }
}



extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIColor {
    public convenience init(_ hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        if ((cString.count) == 8) {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g =  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat((rgbValue & 0x0000FF)) / 255.0
            a = CGFloat((rgbValue & 0xFF000000)  >> 24) / 255.0
            
        }else if ((cString.count) == 6){
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g =  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat((rgbValue & 0x0000FF)) / 255.0
            a =  CGFloat(1.0)
        }
        
        
        self.init(  red: r,
                    green: g,
                    blue: b,
                    alpha: a
        )
    } }

extension String {
    // 正規表現マッチングを実現する
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
    
    // 多言語対応
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}


extension Double {
    // Swiftは桁丸めに対応していなので丸めるやつ
    func round(digit: Int) -> Double {
        return floor((pow(10.0, digit) as NSDecimalNumber).doubleValue * self) / (pow(10.0, digit) as NSDecimalNumber).doubleValue
    }
}

extension Optional {
    var value: String {
        switch self {
        case is Int:
            return String(self as! Int)
        case is Double:
            if (self as! Double).isNaN {
                return String(0.0)
            } else {
                return String(self as! Double)
            }
        case is String:
            return self as! String
        default:
            return "-"
        }
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}

extension JSON {
    var intObject: [Int] {
        let str: String = self.stringValue.replacingOccurrences(of: " ", with: "")
        let substr: String = String(str[str.index(str.startIndex, offsetBy: 1) ..< str.index(str.endIndex, offsetBy: -1)])
        let array: [String] = substr.components(separatedBy: ",")
        let arrayInt: [Int] = array.map({ Int($0)! })
        return arrayInt
    }
}
// 一応実装できた
//extension Results where Iterator.Element == CoopResultsRealm {
//    func all(_ stage_id: Int) -> [CoopResultsRealm] {
//        return Array(self.filter({ $0.stage_id == stage_id && $0.wave.filter({ $0.ikura_num == 0}).count == 0 }))
//    }
//}
