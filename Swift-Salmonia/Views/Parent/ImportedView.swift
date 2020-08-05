
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
            
            if is_imported == true { return }
            
            self.messages.append("Importing Results from Salmon Stats")
            SalmonStats.getResultsLink(nsaid: nsaid) { last, error in
                #if DEBUG
                let last = 3
                #else
                #endif
                for page in 1...last {
                    SalmonStats.importResultsFromSalmonStats(nsaid: nsaid, page: page) { response, error in
                        DispatchQueue(label: "SalmonStats").async {
                            autoreleasepool {
                                guard let realm = try? Realm() else { return } // Realmオブジェクトを作成
                                guard let response = response else { return }
                                realm.beginWrite()

                                for (idx, result) in response {
                                    let object: CoopResultsRealm = SalmonStats.encodeResultToSplatNet2(response: result, nsaid: nsaid)
                                    
                                    // インサートできるかをチェックする
                                    // 他人がアップしたSalmon Statsと自分のリザルトは数秒の差があるのでそこを考慮する
                                    // 10秒以内に新規リザルトをつくることは不可能なのでその間としてみる
                                    let is_valid: Bool = realm.objects(CoopResultsRealm.self).filter({ abs($0.play_time - object.play_time) <= 10 }).count == 0
                                    if is_valid {
                                        realm.create(CoopResultsRealm.self, value: object, update: .modified)
                                    }
                                    self.messages.append("Result: \((page - 1) * 200 + Int(idx)!) -> \(result["id"].intValue) \(is_valid)")
                                    Thread.sleep(forTimeInterval: 0.1)
//                                    break
                                }
                                try? realm.commitWrite()
                            }
                        }
                    }
                }
            }
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
