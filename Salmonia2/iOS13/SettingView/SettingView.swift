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
import SwiftyJSON
import MobileCoreServices
import UserNotifications

struct SettingView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @EnvironmentObject var core: UserResultCore
    @State var isVisible: Bool = false

//    private let realm = try? Realm()
    let version: String = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!))(\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)))"
    
    var body: some View {
        List {
            UserSection
            UserStatus
            Application
        }
        .environmentObject(SalmoniaUserCore())
        .environmentObject(UserResultCore())
        .modifier(Splatfont(size: 20))
        .modifier(SettingsHeader())
        .navigationBarTitle("Settings")
    }
    
    private var Application: some View {
        Section(header: Text("Application").font(.custom("Splatfont", size: 18))) {
            NavigationLink(destination: UnlockFeatureView()) {
                HStack {
                    Text("Unlock")
                    Spacer()
                }
            }
            HStack {
                Text("X-Product Version")
                Spacer()
                Text("\(user.isVersion)")
            }
            HStack {
                Text("Version")
                Spacer()
                Text("\(version)")
            }.onLongPressGesture { isImported() }
        }
    }
    
    private func isImported() {
        guard let realm = try? Realm() else { return }
        guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
        realm.beginWrite()
        user.isImported = false
        try? realm.commitWrite()
    }
    
    private var UserSection: some View {
        Section(header: Text("User").font(.custom("Splatfont", size: 18))) {
            NavigationLink(destination: UserListView()
                            .environmentObject(SalmoniaUserCore())
            ) {
                Text("NSO Accounts")
            }
            NavigationLink(destination: CrewListView()
                            .environmentObject(SalmoniaUserCore())
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
            HStack {
                Text("Local Results")
                Spacer()
                Text("\(core.results.count)")
            }
            HStack {
                Text("Sync UserName")
                Spacer()
            }.onTapGesture { updateUserName() }
            if !user.isImported {
                NavigationLink(destination: ImportResultView()) {
                    HStack {
                        Text("Import Results")
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func updateUserName() {
        guard let realm = try? Realm() else { return }
        autoreleasepool {
            // PlayerResultRealmの名前をアップデートする
            let nsaids: [String] = Array(Set(realm.objects(PlayerResultsRealm.self).map({ $0.nsaid! }))).sorted() // nsaidが空のやつはおらんやろ
            var errids: [String] = []
            realm.beginWrite()
            for nsaid in nsaids {
                let crew = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", nsaid)
                switch crew.isEmpty {
                case true:
                    errids.append(nsaid)
                case false:
                    let user = realm.objects(PlayerResultsRealm.self).filter("nsaid=%@", nsaid)
                    user.setValue(crew.first?.name, forKey: "name")
                }
            }
            if !errids.isEmpty {
                guard let iksm_session = realm.objects(UserInfoRealm.self).first?.iksm_session else { return }
                do {
                    let response: JSON = try SplatNet2.getPlayerNickName(errids, iksm_session: iksm_session)
                    for (_, user) in response {
                        print(user["nickname"].stringValue)
                    }
                } catch (let error) { print(error) }
            }

            try? realm.commitWrite()
        }
    }

}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
