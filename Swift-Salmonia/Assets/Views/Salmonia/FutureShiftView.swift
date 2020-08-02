//
//  FutureShiftView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-01.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import URLImage

struct ShiftCollectionView: View {
    
    private var weapons: [Int] = []
    private var stageid: Int
    private var start_time: String
    private var end_time: String
    
    init(data: JSON) {
        let response = data.dictionaryObject!
        stageid = response["StageID"] as! Int
        weapons = response["WeaponSets"] as! [Int]
        start_time = response["StartDateTime"] as! String
        end_time = response["EndDateTime"] as! String
        
        print(weapons)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                HStack {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/2e4ca1b65a2eb7e4aacf38a8eb88b456.png")!, content: {$0.image.resizable().frame(width: 30, height: 20)})
                    Text(start_time.unix.date).frame(height: 20)
                    Text("-").frame(height: 20)
                    Text(start_time.unix.date).frame(height: 20)
                    Spacer()
                }
                Rectangle().strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5])).frame(height: 2)
                //                Path()
                HStack {
                    URLImage(URL(string: stageid.stage)!, content: {$0.image.renderingMode(.original).resizable().frame(width: 136, height: 76.5)
                    }).clipShape(RoundedRectangle(cornerRadius: 8.0))
                    Spacer()
                    HStack {
                        ForEach(weapons, id:\.self) { id in
                            URLImage(URL(string: id.weapon)!, content: {$0.image.resizable().frame(width: 40, height: 40)})
                        }
                    }
                }
            }
        }
        .frame(height: 120)
        .font(.custom("Splatfont2", size: 18))
    }
}

struct FutureShiftView: View {
    
    private let path = Bundle.main.path(forResource: "coop", ofType:"json")
    private let time = Int(NSDate().timeIntervalSince1970)
    private var phases = [JSON]()
    
    init(){
        guard let response = try? JSON(data: NSData(contentsOfFile: path!) as Data) else { return }
        // 適当に三つくらいのシフトをとってくる
        guard let lastid = response["Phases"].filter({ $0.1["EndDateTime"].stringValue.unix < time }).last?.0 else { return }
        phases = response["Phases"].filter({ Int($0.0)! >= Int(lastid)! }).map({ $0.1 }).prefix(3).map({ $0 })
    }
    
    var body: some View {
        ForEach(phases.indices) { i in
            ShiftCollectionView(data: self.phases[i])
        }
    }
}

struct FutureShiftView_Previews: PreviewProvider {
    static var previews: some View {
        FutureShiftView()
    }
}
