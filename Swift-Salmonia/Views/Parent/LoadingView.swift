//
//  LoadingView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import SwiftyJSON

struct LoadingView: View {
    @State var messages: [String] = []
    
    var body: some View {
        Group {
            Text("Developed by @tkgling")
            Text("Thanks @Yukinkling, @barley_ural")
            Text("External API @frozenpandaman, @nexusmine")
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
            DispatchQueue(label: "SplatNet2").async {
                autoreleasepool {
                    guard let realm = try? Realm() else { return }
                }
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                DispatchQueue.global().async {
                    sleep(1)
                    self.messages.append("Logging Thread")
                }
            }
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread")
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
