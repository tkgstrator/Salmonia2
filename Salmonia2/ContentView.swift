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
        ZStack(alignment: .bottom) {
            NavigationView {
                SalmoniaView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            if !user.isUnlock[4] {
                AdBannerView()
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
