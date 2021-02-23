//
//  ImportResultView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import RealmSwift
import Alamofire
import SwiftyJSON
import SplatNet2

struct SyncUserData: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @State var mainLog: ProgressLog = ProgressLog()
    
    var body: some View {
        LoggingThread(log: $mainLog)
            .navigationBarTitle("Logging Thread", displayMode: .large)
    }
}

//struct ISyncUserData_Previews: PreviewProvider {
//    static var previews: some View {
//        SyncUserData()
//    }
//}

