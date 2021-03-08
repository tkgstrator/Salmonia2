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

    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
            VStack {
                Credit
                Divider()
                MBCircleProgressBar(log: $log, lineWidth: 5, size: 250)
                Spacer()
            }
        }
        .navigationTitle("TITLE_LOGGING_THREAD")
        .navigationBarBackButtonHidden(true)
    }
    
    var Credit: some View {
        VStack {
            Text(verbatim: "Developed by @Herlingum")
            Text(verbatim: "Thanks @Yukinkling, @barley_ural")
            Text(verbatim: "API @frozenpandaman, @nexusmine")
        }
        .minimumScaleFactor(0.7)
        .font(.custom("Roboto Mono", size: 16))
//        .foregroundColor(.white)
    }
}

struct ProgressLog {
    var progress: CGFloat = 0.0 // 進行度を表す値
    var localizedDescription: String? // 現在の状態を出力
    var errorCode: Int? // エラーコード
    var errorDescription: String? // エラーの内容
}
