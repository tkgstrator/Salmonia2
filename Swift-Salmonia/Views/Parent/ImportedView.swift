
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
    
    
    init() {
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
            List {
                ForEach(messages.indices, id: \.self) { idx in
                    Text(self.messages[idx]).frame(height: 14)
                }
            }
            .environment(\.defaultMinListRowHeight, 14)
            .listStyle(PlainListStyle())
        }
        .onAppear() {
            // 最初にiksm_sessionをとっておきます
            
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
