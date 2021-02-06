//
//  SalmoniaView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import UIKit
import SwiftUI
import URLImage
import BetterSafariView
import SafariServices
import AuthenticationServices
import Alamofire

struct SalmoniaView: View {
    
    @EnvironmentObject var user: UserInfoCore
    @EnvironmentObject var account: SalmoniaUserCore
    @State var isVisible: Bool = false
    @State var isSafari: Bool = false

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
            Update().padding(.trailing, 20).padding(.bottom, 60)
        }
        .navigationBarTitle("Salmonia")
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
            NavigationLink(destination: ResultCollectionView(core: UserResultCore())) {
                Text("Job Results")
                    .modifier(Splatfont2(size: 16))
            }
            NavigationLink(destination: WaveCollectionView()) {
                Text("Wave Results")
                    .modifier(Splatfont2(size: 16))
            }
            BSalmonStatsView(isPresented: $isVisible)
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
    
    struct Update: View {
        @State var isComplete = false

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
