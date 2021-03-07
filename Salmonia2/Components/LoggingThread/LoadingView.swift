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
    @EnvironmentObject var user: UserInfoCore
    @EnvironmentObject var main: MainCore
    @Environment(\.presentationMode) var present
    
    @State var mainlog: ProgressLog = ProgressLog()
    @State var isActive: Bool = false
    @State var isError: Bool = false
    @State var appError: APPError = .unknown
    
    var body: some View {
        LoggingThread(log: $mainlog)
            .onAppear {
                // TODO: エラーを出力するように変更する
                let iksm_session: String = ""
                //            guard let iksm_session: String = user.iksm_session else { return }
                let api_token: String = ""
//                guard let api_token: String = main.apiToken else { return }
                guard let version: String = user.version else { return }
                guard let session_token: String = user.session_token else { return }
                guard let nsaid: String = user.nsaid else { return }
                let local_job_num: Int = 500
                
                DispatchQueue(label: "LoadingView").async {
                    do {
                        throw APPError.active
                        // イカスミセッションが切れていた場合
                        if !SplatNet2.isValid(iksm_session: user.iksm_session!) {
                            let response: JSON = try SplatNet2.genIksmSession(session_token, version: version)
                            user.iksm_session = response["iksm_session"].string
                        }
                        // シフトデータを取得
                        let summary: JSON = try SplatNet2.getSummary(iksm_session: user.iksm_session!)
                        guard var dict_summary: [String: Any] = summary["summary"]["card"].dictionaryObject else { throw APPError.coop } // とりあえず適当なエラーを吐く
                        dict_summary.updateValue(nsaid, forKey: "nsaid") // データにプレイヤーIDを追加
                        print(dict_summary)
                        guard let remote_job_num: Int = summary["summary"]["card"]["job_num"].int else { return }
                        // TODO: ここもエラー表示に対応したい
                        if local_job_num == remote_job_num { return }
                        let job_num: Range<Int> = Range(max(remote_job_num - 49, local_job_num + 1) ... remote_job_num)
                        
                        var results: [JSON] = []
                        // リザルトを取得
                        for (idx, job_id) in job_num.enumerated() {
                            mainlog.progress = CGFloat(idx + 1) / CGFloat(job_num.count)
                            results.append(try SplatNet2.getResult(job_id: job_id, iksm_session: user.iksm_session!))
                        }
                        
                        // 10件ずつアップロードする
                        let dict_results: [[Dictionary<String, Any>]] = results.map{ $0.dictionaryObject! }.chunked(by: 10)
                        for result in dict_results {
                            //                        let response: JSON = try SalmonStats.uploadSalmonStats(token: api_token, result)
                            //                        let ids: [(Int, Int)] = response.map{ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) }
                            Thread.sleep(forTimeInterval: 5)
                        }
                        DispatchQueue.main.async {
                            self.present.wrappedValue.dismiss()
                        }
                    } catch {
                        appError = error as! APPError
                        isError.toggle()
                    }
                }
            }
            .alert(isPresented: $isError) {
                Alert(title: Text("Code: \(appError.errorCode)"),
                      message: Text(appError.localizedDescription),
                      dismissButton:
                        .default(
                            Text("BTN_CONFIRM"),
                            action: { present.wrappedValue.dismiss() }
                        ))
            }
    }
}
