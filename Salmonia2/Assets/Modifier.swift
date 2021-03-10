//
//  Modifier.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI

struct AlertView: ViewModifier {
    @Binding var isPresented: Bool
    let error: CustomNSError

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(title: Text("ERROR_CODE_\(String(error.errorCode))"), message: Text(error.localizedDescription))
            }
    }
}
 
extension View {
    func alert(isPresented: Binding<Bool>, error: CustomNSError?) -> some View {
        guard let error = error else { return AnyView(self) }
        return AnyView(self.modifier(AlertView(isPresented: isPresented, error: error)))
    }
}
