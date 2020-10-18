//
//  ContentView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            SalmoniaView()
        }
        .environmentObject(UserInfoCore())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
