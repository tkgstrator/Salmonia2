
//
//  ImportedView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON
import CryptoSwift

struct ImportedView: View {
    @State var messages: [String] = []
    
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
            //            List {
            //                ForEach(messages.indices, id: \.self) { idx in
            //                    Text(self.messages[idx])
            //                }
            //            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Logging Thread").frame(maxWidth: .infinity)
                    ForEach(messages.indices, id: \.self) { idx in
                        Text(self.messages[idx])
                    }
                }
            }
        }
        .onAppear() {
            // 最初にiksm_sessionをとっておきます
            guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
            guard let is_imported: Bool = realm.objects(UserInfoRealm.self).first?.is_imported else { return }
            guard let nsaid: String = realm.objects(UserInfoRealm.self).first?.nsaid else { return }
            let results: [Int] = realm.objects(CoopResultsRealm.self).map({ $0.play_time })
            if is_imported == true { return }
            
            self.messages.append("Importing Results from Salmon Stats")
            SalmonStats.getResultsLink(nsaid: nsaid) { last, error in
                #if DEBUG
                let last = 3
                #else
                #endif
                DispatchQueue(label: "GetPages").async {
                    for page in 1...last {
                        SalmonStats.importResultsFromSalmonStats(nsaid: nsaid, page: page) { response, error in
                            DispatchQueue(label: "SalmonStats").async {
                                autoreleasepool {
                                    guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                    guard let response = response else { return }
                                    realm.beginWrite()
                                    for (idx, result) in response {
                                        let start_time = Unixtime(time: result["start_at"].stringValue)
                                        // 10秒以内に新規リザルトをつくることは不可能なのでその間としてみる
                                        let is_valid: Bool = results.filter({ abs($0 - start_time) <= 10 }).count == 0
                                        if is_valid {
                                            let object: CoopResultsRealm = SalmonStats.encodeResultToSplatNet2(response: result, nsaid: nsaid)
                                            realm.create(CoopResultsRealm.self, value: object, update: .modified)
                                        }
                                        print("\((page - 1) * 200 + Int(idx)!) -> \(result["id"].intValue) \(is_valid)")
                                        self.messages.append("Result: \((page - 1) * 200 + Int(idx)!) -> \(result["id"].intValue) \(is_valid)")
                                        Thread.sleep(forTimeInterval: 0.1)
                                    } // For
                                    try? realm.commitWrite()
                                } // autoreleasepool
                            } // DispatchQueue in closure
                            Thread.sleep(forTimeInterval: 20)
                        } // importResultsFromSalmonStats
                    } // For
                } // DispatchQueue
            } // GetResultsLink
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread")
    }
}

struct ImportedView_Previews: PreviewProvider {
    static var previews: some View {
        ImportedView()
    }
}
