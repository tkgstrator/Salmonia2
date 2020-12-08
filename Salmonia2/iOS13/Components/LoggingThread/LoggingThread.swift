//
//  LoggingThread.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct LoggingThread: View {
    @Binding var log: Log
    @State var elapsedTime: Double = 0.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            VStack {
                Text("Developed by @Herlingum")
                Text("Thanks @Yukinkling, @barley_ural")
                Text("API @frozenpandaman, @nexusmine")
            }
            .font(.custom("Roboto Mono", size: 18))
            Divider()
            VStack {
                HStack {
                    Text("Status:")
                    Spacer()
                    if log.isValid == true {
                        if log.progress.min != nil && log.progress.min == log.progress.max {
                            Text("Done").onAppear() {
                                log.isLock = false
                            }
                        } else {
                            Text("\(log.status.value)")
                        }
                    } else {
                        Text("\(log.errorDescription.value)")
                    }
                }
                HStack {
                    Text("Results:")
                    Spacer()
                    if log.isValid == true {
                        Text("\(log.progress.id.value)(\(log.progress.min.value)/\(log.progress.max.value))")
                    } else {
                        Text("-(-/-)")
                    }
                }
            }
            .font(.custom("Roboto Mono", size: 22))
            .padding(.horizontal, 16)
            Spacer()
            Paypal
        }
        .navigationBarTitle("Logging Thread", displayMode: .large)
        .navigationBarBackButtonHidden(log.isLock)
    }
    
    private var Paypal: some View {
        Image("Paypal")
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .padding(.bottom)
            .onTapGesture {
            UIApplication.shared.open(URL(string: "https://www.paypal.me/salmonia")!)
        }
    }
}


struct LoggingThread_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World")
        //        LoggingThread()
    }
}
