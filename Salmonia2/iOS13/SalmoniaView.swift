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

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List  {
                Section(header: Text("Overview").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    User
                    Status
                    Results
                }
                Section(header: Text("Shift Schedule").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    CoopShiftView()
                }
                Section(header: Text("Stage Records").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    StageRecordView()
                }
            }
            Update().padding(.trailing, 20).padding(.bottom, 20)
        }
        .navigationBarTitle("Salmonia")
//        .navigationBarItems(leading: Setting, trailing: HStack(spacing: 15) {
//            Search
//            SalmonStats
//        })
    }
    
    private var Title: some View {
        Text("Salmonia")
            .modifier(Splatfont(size: 24))
    }
    
    private var User: some View {
        NavigationLink(destination: SettingView()) {
            HStack {
                URLImage(url: URL(string: user.imageUri)!) { image in image.resizable().clipShape(Circle()) }.frame(width: 70, height: 70)
                Text(user.nickname)
                    .modifier(Splatfont(size: 20))
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var Results: some View {
        Group {
            NavigationLink(destination: ResultCollectionView()) {
                Text("Job Results")
                    .modifier(Splatfont2(size: 16))
            }
            NavigationLink(destination: WaveCollectionView()) {
                Text("Wave Results")
                    .modifier(Splatfont2(size: 16))
            }
            NavigationLink(destination: WebBrowser(address: "https://salmon-stats-api.yuki.games/auth/twitter"))
            {
                Text("Salmon Stats")
                    .modifier(Splatfont2(size: 16))
            }
//            NavigationLink(destination: PastCoopShiftView()) {
//                Text("Coop Shift Rotation")
//                    .modifier(Splatfont2(size: 16))
//            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var Status: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Text("Jobs")
                Text("\(user.job_num)")
            }
            Spacer()
            VStack(spacing: 0) {
                Text("Eggs")
                HStack {
                    Text("\(user.golden_ikura_total)").foregroundColor(.yellow)
                    Text("/")
                    Text("\(user.ikura_total)").foregroundColor(.red)
                }
            }
            Spacer()
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var Search: some View {
        NavigationLink(destination: WaveCollectionView()) {
            Image(systemName: "magnifyingglass").resizable().scaledToFit().frame(width: 30, height: 30)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
//    private var SalmonStats: some View {
//        NavigationLink(destination: WebKitView())
//        {
//            Image(systemName: "snow").resizable().scaledToFit().frame(width: 30, height: 30)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }

    private var Setting: some View {
        NavigationLink(destination: SettingView()){
            URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/bb035c04e62c044139986540e6c3b8b3.png")!) { image in image.renderingMode(.template).resizable() }
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
                    Circle().frame(width: 60, height: 60).foregroundColor(.cBlue)
                    URLImage(url: URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!) { image in image.renderingMode(.original).resizable() }
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
