//
//  LoadingView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import RealmSwift
import Alamofire
import SplatNet2
import SwiftyJSON

struct LoadingView: View {
    @State var mainlog: ProgressLog = ProgressLog()
    @State var isActive: Bool = false
    @State var isError: Bool = false
    @State var appError: APPError = .unknown
    
    var body: some View {
        Group {
            NavigationLink(destination: SalmoniaView(), isActive: $isActive) { EmptyView() }
            LoggingThread(log: $mainlog)
        }
        .onAppear {
            // 本来はUserDefaultsから取得すべき値
            let iksm_session: String = "f4b4f3d04ebef94907976505c92a4598a5e3504d"
            let api_token: String = "e177c07226e9195215a43a7686401852542cc5aa52899bf47834b8a9f4803cbb"
            let version: String = "1.10.1"
            let session_token: String = ""
            let nsaid: String = "91d160aa84e88da6"
            let local_job_num: Int = 480
            
            DispatchQueue(label: "LoadingView").async {
                do {
//                    throw APPError.active
                    // イカスミセッションが切れていた場合
                    if !SplatNet2.isValid(iksm_session: iksm_session) {
                        let response: JSON = try SplatNet2.genIksmSession(session_token, version: version)
                        print(response)
                    }
                    // シフトデータを取得
                    let summary: JSON = try SplatNet2.getSummary(iksm_session: iksm_session)
                    guard var dict_summary: [String: Any] = summary["summary"]["card"].dictionaryObject else { throw APPError.coop } // とりあえず適当なエラーを吐く
                    dict_summary.updateValue(nsaid, forKey: "nsaid") // データにプレイヤーIDを追加
                    print(dict_summary)
                    guard let remote_job_num: Int = summary["summary"]["card"]["job_num"].int else { return }
                    if local_job_num == remote_job_num {
                        return
                    }
                    let job_num: Range<Int> = Range(max(remote_job_num - 49, local_job_num + 1) ... remote_job_num)
                    
                    var results: [JSON] = []
                    // リザルトを取得
                    for (idx, job_id) in job_num.enumerated() {
                        mainlog.progress = CGFloat(idx + 1) / CGFloat(job_num.count)
                        results.append(try SplatNet2.getResult(job_id: job_id, iksm_session: iksm_session))
                    }
                    
                    // 10件ずつアップロードする
                    let dict_results: [[Dictionary<String, Any>]] = results.map{ $0.dictionaryObject! }.chunked(by: 10)
                    for result in dict_results {
                        //                        let response: JSON = try SalmonStats.uploadSalmonStats(token: api_token, result)
                        //                        let ids: [(Int, Int)] = response.map{ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) }
                        Thread.sleep(forTimeInterval: 5)
                    }
                    isActive.toggle()
                } catch {
                    appError = error as! APPError
                    isError.toggle()
                }
            }
        }
        .alert(isPresented: $isError) {
            Alert(title: Text("Code: \(appError.errorCode)"), message: Text(appError.localizedDescription), dismissButton: .default(Text("BTN_CONFIRM"), action: { isActive.toggle() }))
        }
    }
}

class Salmonia2 {
    // リザルト一覧から取得するための関数
    class func updateResults() throws -> Void {
        // 本来はUserDefaultsから取得すべき値
        let iksm_session: String = ""
        //        let iksm_session: String = "3dd87fd0d012041d3a9f23498fba7cd40381d622"
        let api_token: String = "e177c07226e9195215a43a7686401852542cc5aa52899bf47834b8a9f4803cbb"
        let version: String = "1.10.1"
        let session_token: String = ""
        let nsaid: String = "91d160aa84e88da6"
        let local_job_num: Int = 430
        
        // イカスミセッションが切れていた場合
        if !SplatNet2.isValid(iksm_session: iksm_session) {
            let response: JSON = try SplatNet2.genIksmSession(session_token, version: version)
            print(response)
        }
        // シフトデータを取得
        let summary: JSON = try SplatNet2.getSummary(iksm_session: iksm_session)
        guard var dict_summary: [String: Any] = summary["summary"]["card"].dictionaryObject else { throw APPError.coop } // とりあえず適当なエラーを吐く
        dict_summary.updateValue(nsaid, forKey: "nsaid") // データにプレイヤーIDを追加
        print(dict_summary)
        guard let remote_job_num: Int = summary["summary"]["card"]["job_num"].int else { return }
        if local_job_num == remote_job_num {
            return
        }
        let job_num: Range<Int> = Range(max(remote_job_num - 49, local_job_num + 1) ... remote_job_num)
        
        var results: [JSON] = []
        // リザルトを取得
        for (idx, job_id) in job_num.enumerated() {
            //                    mainlog.progress = CGFloat(idx + 1) / CGFloat(job_num.count)
            results.append(try SplatNet2.getResult(job_id: job_id, iksm_session: iksm_session))
        }
        
        // 10件ずつアップロードする
        let dict_results: [[Dictionary<String, Any>]] = results.map{ $0.dictionaryObject! }.chunked(by: 10)
        for result in dict_results {
            //                        let response: JSON = try SalmonStats.uploadSalmonStats(token: api_token, result)
            //                        let ids: [(Int, Int)] = response.map{ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) }
            Thread.sleep(forTimeInterval: 5)
            print("Uploaded")
        }
    }
}
