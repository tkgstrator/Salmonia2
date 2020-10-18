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
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Splatfont", size: 20)!]
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "Splatfont", size: 20)!]
    }
    
    var body: some View {
        ScrollView  {
            PlayerView().padding(.top, 15)
            CoopShiftView()
            StageRecordView()
            OptionView()
        }
        .environmentObject(UserInfoCore())
        .environmentObject(CoopShiftCore())
        .environmentObject(UserResultCore())
        //        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(leading: Title, trailing: Setting)
    }
    
    private var Title: some View {
        Text("Salmonia").font(.custom("Splatfont", size: 22))
    }
    
    private var User: some View {
        HStack {
            URLImage(URL(string: user.imageUri)!, content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                .frame(width: 35, height: 35)
            Spacer()
            Text(user.nickname).modifier(Splatfont(size: 24)).frame(maxWidth: .infinity)
        }
    }
    
    private var Setting: some View {
        NavigationLink(destination: SettingView().environmentObject(SalmoniaUserCore())){
            URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/bb035c04e62c044139986540e6c3b8b3.png")!,
                     content: {$0.image.renderingMode(.template).resizable()})
                .frame(width: 30, height: 30).foregroundColor(.white)
        }
    }
    
    private var Update: some View {
        NavigationLink(destination: LoadingView()){
            URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/50732dded088309dfb8f436f3885e782.png")!,
                     content: {$0.image.renderingMode(.original).resizable()})
                .frame(width: 30, height: 30)
        }
    }
}

struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
