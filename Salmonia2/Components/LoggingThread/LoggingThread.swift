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
        .navigationTitle("TITLE_LOGGING_THREAD")
        .navigationBarBackButtonHidden(true)
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

struct ProgressLog {
    var progress: CGFloat = 0.0 // 進行度を表す値
    var localizedDescription: String? // 現在の状態を出力
    var errorCode: Int? // エラーコード
    var errorDescription: String? // エラーの内容
}
