//
//  SalmoniaView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import URLImage

struct SalmoniaView: View {
    
    @EnvironmentObject var user: UserInfoCore
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Splatfont", size: 36)!]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Splatfont", size: 20)!]
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView  {
                PlayerView().padding(.top, 15)
                CoopShiftView()
                StageRecordView()
                OptionView()
            }
            Update().padding(.trailing, 20).padding(.bottom, 20)
        }
        .environmentObject(UserInfoCore())
        .environmentObject(CoopShiftCore())
        .environmentObject(UserResultCore())
//        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: Title, trailing: HStack(spacing: 15) {
            Search
            SalmonStats
            Setting
        })
    }
    
    private var Title: some View {
        Text("Salmonia").font(.custom("Splatfont", size: 24))
    }
    
    private var User: some View {
        HStack {
            URLImage(URL(string: user.imageUri)!, content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                .frame(width: 35, height: 35)
            Spacer()
            Text(user.nickname).modifier(Splatfont(size: 24)).frame(maxWidth: .infinity)
        }
    }
    
    private var Search: some View {
        NavigationLink(destination: WaveCollectionView().environmentObject(WaveResultCore())) {
            Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var SalmonStats: some View {
        NavigationLink(destination: WebKitView())
        {
            Image(systemName: "snow").resizable().scaledToFit().frame(width: 30, height: 30)
        }.buttonStyle(PlainButtonStyle())
    }

    private var Setting: some View {
        NavigationLink(destination: SettingView().environmentObject(SalmoniaUserCore())){
            URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/bb035c04e62c044139986540e6c3b8b3.png")!,
                     content: {$0.image.renderingMode(.template).resizable()})
                .frame(width: 30, height: 30).foregroundColor(.white)
        }
    }
    
    struct Update: View {
        @GestureState var isLongPress = false
        @State var isComplete = false
        
        var longPress: some Gesture {
            LongPressGesture(minimumDuration: 0.3, maximumDistance: 1.0)
                .updating($isLongPress) { current, gesture, transaction in
                    gesture = current
                    transaction.animation = Animation.easeIn(duration: 2.0)
                }
                .onEnded { finished in
                    isComplete = finished
                }
        }
        
        var body: some View {
            NavigationLink(destination: LoadingView()){
                ZStack {
                    Circle().frame(width: 60, height: 60).foregroundColor(.cDarkGray)
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                             content: {$0.image.renderingMode(.original).resizable()})
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}

struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
