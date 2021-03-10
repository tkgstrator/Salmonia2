//
//  ContentView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var unlock: UnlockCore
    @EnvironmentObject var main: MainCore

    var body: some View {
        switch main.isLogin {
        case true:
            TopView
                .animation(.linear)
        case false:
            LoginView
                .animation(.linear)
        }
    }
    
    var TopView: some View {
        NavigationView {
            SalmoniaView()
            ResultCollectionView()
        }
        .navigationViewStyle(LegacyNavigationViewStyle())
    }
    
    var LoginView: some View {
        NavigationView {
            LoginMenu()
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }

    var BackGround: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
