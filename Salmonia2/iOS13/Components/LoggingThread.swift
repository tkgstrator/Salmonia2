//
//  LoggingThread.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI

struct LoggingThread: View {
    @Binding var log: [String]
    @Binding var lock: Bool
    
    init(log: Binding<[String]>, lock: Binding<Bool>) {
        _log = log
        _lock = lock
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        Group {
            VStack {
                Text("Developed by @tkgling")
                Text("Thanks @Yukinkling, @barley_ural")
                Text("External API @frozenpandaman, @nexusmine")
            }
            //            if #available(iOS 14.0, *) {
            //                ScrollView {
            //                    LazyVStack(alignment: .leading) {
            //                        ForEach(log.indices, id:\.self) { idx in
            //                            Text(self.log[idx]).frame(height: 22)
            //                        }
            //                    }
            //                }.padding(.horizontal, 14)
            //            } else {
            if #available(iOS 14.0, *) {
                ScrollViewReader { proxy in
                    List() {
                        ForEach(log.indices, id:\.self) { idx in
                            Text(self.log[idx]).frame(height: 10).id(idx)
                        }
                    }
                    .environment(\.defaultMinListRowHeight, 0)
                }
            } else {
                List() {
                    ForEach(log.indices, id:\.self) { idx in
                        Text(self.log[idx]).frame(height: 10)
                    }
                }
                .environment(\.defaultMinListRowHeight, 0)
            }
        }
        .font(.custom("Roboto Mono", size: 14))
        .navigationBarTitle("Logging Thread", displayMode: .large)
//        .navigationBarBackButtonHidden(lock)
    }
}

struct LoggingThread_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World")
        //        LoggingThread()
    }
}
