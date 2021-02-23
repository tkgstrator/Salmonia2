//
//  LoggingThread.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct LoggingThread: View {
    @Binding var log: ProgressLog
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            Credit
            Divider()
            MBCircleProgressBar(log: $log, lineWidth: 5, color: Color.red, size: 250)
            Spacer()
        }
        .navigationBarTitle("Logging Thread", displayMode: .large)
    }
    
    var Credit: some View {
        VStack {
            Text("Developed by @Herlingum")
                .minimumScaleFactor(0.7)
            Text("Thanks @Yukinkling, @barley_ural")
                .minimumScaleFactor(0.7)
            Text("API @frozenpandaman, @nexusmine")
                .minimumScaleFactor(0.7)
        }
        .font(.custom("Roboto Mono", size: 16))
    }
}
