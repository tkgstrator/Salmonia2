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
import SwiftUIRefresh

struct SalmoniaView: View {
    
    @EnvironmentObject var user: UserInfoCore

    @State var isVisible: Bool = false
    @State var isActive: Bool = false
    @State var isShowing: Bool = false

    var body: some View {
        ZStack {
            NavigationLink(destination: LoadingView(), isActive: $isActive) { EmptyView() }
            List {
                Section(header: Text("HEADER_OVERVIEW").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    User
                    Status
                    Results
                }
                Section(header: Text("HEADER_SCHEDULE").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    CoopShiftView()
                }
                Section(header: Text("HEADER_RECORDS").modifier(Splatfont2(size: 16)).foregroundColor(.cOrange)) {
                    StageRecordView()
                }
            }
        }
        .pullToRefresh(isShowing: $isShowing) {
            isActive.toggle()
            isShowing.toggle()
        }
        .navigationTitle("TITLE_SALMONIA")
        .navigationBarBackButtonHidden(true)
    }
    
    private var User: some View {
        NavigationLink(destination: SettingView()) {
            HStack {
                URLImage(url: URL(string: user.imageUri)!) { image in image.resizable().clipShape(Circle()) }.frame(width: 70, height: 70)
                Text(user.nickname)
                    .modifier(Splatfont2(size: 18))
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var Results: some View {
        Group {
            NavigationLink(destination: ResultCollectionView()) {
                Text("TITLE_JOB_RESULTS")
                    .modifier(Splatfont2(size: 16))
            }
            NavigationLink(destination: WaveCollectionView()) {
                Text("TITLE_WAVE_RESULTS")
                    .modifier(Splatfont2(size: 16))
            }
            BSalmonStatsView(isPresented: $isVisible)
        }
    }
    
    private var Status: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Text("OVERVIEW_JOBS")
                Text("\(user.job_num)")
            }
            Spacer()
            VStack(spacing: 0) {
                Text("OVERVIEW_EGGS")
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
}

struct SalmoniaView_Previews: PreviewProvider {
    static var previews: some View {
        SalmoniaView()
    }
}
