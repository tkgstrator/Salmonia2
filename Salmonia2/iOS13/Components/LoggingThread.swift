//
//  LoggingThread.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI

struct LoggingThread: View {
    @Binding var log: Log
    @State var elapsedTime: Double = 0.0
    @State var isLock = true
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            VStack {
                Text("Developed by @tkgling")
                Text("Thanks @Yukinkling, @barley_ural")
                Text("API @frozenpandaman, @nexusmine")
            }
            .font(.custom("Roboto Mono", size: 18))
            Divider()
            VStack {
                HStack {
                    Text("Status:")
                    Spacer()
                    if log.progress.min != nil {
                        if log.progress.min.value == log.progress.max.value {
                            Text("Done")
                        } else {
                            Text(log.status.value)
                        }
                    } else {
                        Text("Preparing")
                    }
                }
                HStack {
                    Text("Results:")
                    Spacer()
                    Text("\(log.progress.id.value)(\(log.progress.min.value)/\(log.progress.max.value))")
                }
            }
            .font(.custom("Roboto Mono", size: 22))
            .padding(.horizontal, 20)
        }
        Spacer()
        .navigationBarTitle("Logging Thread", displayMode: .large)
            .navigationBarBackButtonHidden(log.progress.min.value != log.progress.max.value)
    }
}

struct LoggingThread_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World")
        //        LoggingThread()
    }
}
