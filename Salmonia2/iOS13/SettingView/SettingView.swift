//
//  SettingView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import SwiftUI
import SplatNet2
import RealmSwift
import WebKit
import MobileCoreServices

struct SettingView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @State var isVisible: Bool = false

    let version: String = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!))(\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)))"
    
    var body: some View {
        List {
            UserSection
            UserStatus
            Application
        }
        .navigationBarTitle("Settings")
        .environmentObject(SalmoniaUserCore())
        .modifier(Splatfont(size: 20))
        .modifier(SettingsHeader())
    }
    
    private var Application: some View {
        Section(header: Text("Application").font(.custom("Splatfont", size: 18))) {
            NavigationLink(destination: UnlockFeatureView()) {
                HStack {
                    Text("Unlock")
                    Spacer()
                    Text("Feature")
                }
            }
            NavigationLink(destination: ImportResultView()) {
                            HStack {
                                Text("Import Results")
                                Spacer()
//                                Text("Feature")
                            }
                        }
            HStack {
                Text("Version")
                Spacer()
                Text("\(version)")
            }
        }
    }
    
    private var UserSection: some View {
        Section(header: Text("User").font(.custom("Splatfont", size: 18))) {
            NavigationLink(destination: UserListView()
                            .environmentObject(SalmoniaUserCore())
            ) {
                Text("NSO Accounts")
            }
            NavigationLink(destination: CrewListView()
                            .environmentObject(CrewInfoCore())
            ) {
                Text("Fav Crews")
            }
        }
    }
    
    private var UserStatus: some View {
        Section(header: Text("Status").font(.custom("Splatfont", size: 18))) {
            HStack {
                Text("laravel session")
                Spacer()
                Text("\((user.api_token != nil ? "Registered" : "Unregistered").localized)")
            }
        }
    }
}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
