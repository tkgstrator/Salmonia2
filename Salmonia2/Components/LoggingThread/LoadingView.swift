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
//                guard let iksm_session: String = user.iksm_session else { return }
                guard let api_token: String = user.api_token else { return }
                guard let version: String = user.version else { return }
                guard let session_token: String = user.session_token else { return }
                guard let nsaid: String = user.nsaid else { return }
                print(user.iksm_session, api_token)

                DispatchQueue(label: "LoadingView").async {
                    do {
                        // TODO: ここでいろいろエラー発生させて検証
//                        throw APPError.empty
                        
                        // DispatchQueue内では別にオブジェクトを用意する必要がある
                        guard let realm = try? Realm() else { return }
                        // イカスミセッションが切れていた場合
                        if !SplatNet2.isValid(iksm_session: user.iksm_session!) {
                            let response: JSON = try SplatNet2.genIksmSession(user.session_token!, version: user.version!)
                            user.iksm_session = response["iksm_session"].string
                        }
                        // シフトデータを取得
                        let summary: JSON = try SplatNet2.getSummary(iksm_session: user.iksm_session!)
                        guard var dict_summary: [String: Any] = summary["summary"]["card"].dictionaryObject else { throw APPError.coop } // とりあえず適当なエラーを吐く
                        dict_summary.updateValue(nsaid, forKey: "nsaid") // データにプレイヤーIDを追加

                        guard let remote_job_num: Int = summary["summary"]["card"]["job_num"].int else { return }
                        // TODO: ここもエラー表示に対応したい
                        #if DEBUG
                        let job_num: Range<Int> = Range(max(remote_job_num - 49, remote_job_num - 25) ... remote_job_num)
                        #else
                        if user.job_num == remote_job_num { throw APPError.empty }
                        let job_num: Range<Int> = Range(max(remote_job_num - 49, user.job_num + 1) ... remote_job_num)
                        #endif
                        
                        var results: [JSON] = []
                        // リザルトを取得
                        for (idx, job_id) in job_num.enumerated() {
                            mainlog.progress = CGFloat(idx + 1) / CGFloat(job_num.count)
                            results.append(try SplatNet2.getResult(job_id: job_id, iksm_session: user.iksm_session!))
                        }
                        
                        // 10件ずつアップロードする
                        let dict_results: [[Dictionary<String, Any>]] = results.map{ $0.dictionaryObject! }.chunked(by: 10)
                        for result in dict_results {
                            mainlog.progress += 1 / CGFloat(dict_results.count)
                            //                        let response: JSON = try SalmonStats.uploadSalmonStats(token: api_token, result)
                            //                        let ids: [(Int, Int)] = response.map{ ($0.1["job_id"].intValue, $0.1["salmon_id"].intValue) }
                            Thread.sleep(forTimeInterval: 2)
                        }
                        
                        // TODO: ここで更新しないと取得漏れが発生する
                        // データベースのデータを更新する
                        realm.beginWrite()
                        realm.create(UserInfoRealm.self, value: dict_summary as Any, update: .modified)
                        try realm.commitWrite()

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
                Alert(title: Text("ERROR_CODE_\(String(appError.errorCode))"),
                      message: Text(appError.errorDescription!.localized),
                      dismissButton:
                        .default(
                            Text("BTN_CONFIRM"),
                            action: { present.wrappedValue.dismiss() }
                        ))
            }
    }
}
