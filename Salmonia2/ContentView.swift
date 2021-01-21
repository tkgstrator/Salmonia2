//
//  ContentView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    var body: some View {
        VStack {
            NavigationView {
                SalmoniaView()
            }
            if !user.isUnlock[3] {
                AdBannerView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .listStyle(GroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
