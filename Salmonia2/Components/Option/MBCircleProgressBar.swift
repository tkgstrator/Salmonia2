//
//  MBCircleProgressBar.swift
//  Salmonia2
//
//  Created by Devonly on 2021/02/23.
//

import SwiftUI

struct MBCircleProgressBar: View {
    @Binding var log: ProgressLog
    @State var lineWidth: CGFloat
    @State var color: [Color] = [.red, .blue]
    @State var size: CGFloat
    
    var body: some View {
        Group {
            ZStack {
                Circle().stroke(Color.gray, lineWidth: lineWidth)
                    .opacity(0.1)
                Group {
                    Circle()
                        .trim(from: 0, to: log.progress)
                        .stroke(color[0], lineWidth: lineWidth)
                        .rotationEffect(.degrees(-90))
                    Circle()
                        .trim(from: 0, to: log.progress >= 1.0 ? log.progress - 1.0 : 0.0)
                        .stroke(color[1], lineWidth: lineWidth)
                        .rotationEffect(.degrees(-90))
                }
                .opacity(0.8)
                .overlay(
                    VStack {
                        Text(String(log.progress.round) + "%")
                        Text(log.progress > 1.0 ? "LOG_UPLOAD" : "LOG_DOWNLOAD")
                    }
                    .font(.custom("Roboto Mono", size: 20)))
            }
            .animation(.easeOut(duration: 0.2))
            .padding(.all, 20)
            .frame(height: size)
        }
    }
}

private extension CGFloat {
    var round: Double {
        let value: Double = self > 1.0 ? Double(self) - 1.0 : Double(self)
        return Double(Int(value * 10000)) / Double(100)
    }
}
