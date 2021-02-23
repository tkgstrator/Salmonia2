//
//  LoggingView.swift
//  Salmonia2
//
//  Created by Devonly on 2021/02/23.
//

import SwiftUI

struct LoggingView: View {
    @Binding var errorCode: String
    @Binding var errorDescription: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Error Code:")
                Spacer()
                Text("\(errorCode)")
            }
            HStack {
                Text("Description:")
                Spacer()
                Text("\(errorDescription)")
            }
        }
        .padding(.horizontal, 10)
        .font(.custom("Roboto Mono", size: 16))
    }
}

//struct LoggingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoggingView(errorCode: <#T##Binding<String>#>, errorDescription: <#T##Binding<String>#>)
//    }
//}
