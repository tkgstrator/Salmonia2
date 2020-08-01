//
//  Alert.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-01.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct AlertView: View {
    @Binding var title: String
    @Binding var message: String

    var body: some View {
        Alert(title: "Hello, World")
    }
}

//struct AlertV_Previews: PreviewProvider {
//    static var previews: some View {
//        Alert()
//    }
//}
