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
    @State var color: Color
    @State var size: CGFloat
    
    var body: some View {
        Group {
            ZStack {
                Circle().stroke(Color.gray, lineWidth: lineWidth)
                    .opacity(0.1)
                Circle()
                    .trim(from: 0, to: log.progress)
                    .stroke(color, lineWidth: lineWidth)
                    .rotationEffect(.degrees(-90))
                    .opacity(0.8)
                    .overlay(Text(String(log.progress.round) + "%"))
                    .font(.custom("Roboto Mono", size: 16))
                    .animation(.easeOut(duration: 0.2))
            }
            .padding(.all, 20)
            .frame(height: size)
            // ログ表示
            if log.errorCode != nil {
                Group {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Error Code:")
                            Spacer()
                            Text("\(log.errorCode.value)")
                        }
                        HStack {
                            Text("Error Description:")
                            Spacer()
                            Text("\(log.errorDescription.value)")
                        }
                        HStack {
                            Text("\(log.localizedDescription.value)")
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .font(.custom("Roboto Mono", size: 16))
            }
        }
    }
}

//struct MBCircleProgressBar_Previews: PreviewProvider {
//    static var previews: some View {
//        MBCircleProgressBar(progress: 1/7, lineWidth: 10, color: Color.red, size: 100)
//    }
//}

private extension CGFloat {
    var round: Double {
        return Double(Int(self * 10000)) / Double(100)
    }
}
