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

struct ImportResultView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @State var mainLog: ProgressLog = ProgressLog()

    var body: some View {
        LoggingThread(log: $mainLog)
            .navigationBarTitle("Logging Thread", displayMode: .large)
    }
    

    private func getResults(nsaid: String, page: Int) throws -> JSON {
        let url = "https://salmon-stats-api.yuki.games/api/players/\(nsaid)/results?raw=0&count=200&page=\(page)"
        print(url)
        let json = try SAF.request(url)
        return json["results"]
    }
    
    private func getLastLink(nsaid: String) throws -> (link: Int, job_num: Int){
        let url = "https://salmon-stats-api.yuki.games/api/players/metadata/?ids=\(nsaid)"
        let json = try SAF.request(url)
        
        let metadata = json[0]["results"]
        let job_num: Int = metadata["clear"].intValue + metadata["fail"].intValue
        let lastlink = ((metadata["clear"].intValue + metadata["fail"].intValue) / 200) + 1
        return (lastlink, job_num)
    }
    
}

//struct ImportResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImportResultView()
//    }
//}
