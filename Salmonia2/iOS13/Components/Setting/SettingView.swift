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
import Alamofire
import UserNotifications
import AVKit
import SafariServices

struct SettingView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @EnvironmentObject var core: UserResultCore
    @State var isVisible: Bool = false
    
    let version: String = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!))(\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)))"
    
    var body: some View {
        List {
            UserSection
            UserStatus
            Application
        }
//        .modifier(Splatfont2(size: 16))
//        .listStyle(GroupedListStyle())
        .navigationBarTitle("Settings")
    }
    
    private var Application: some View {
        Section(header: Text("Application")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange))
        {
            HStack {
                Text("How to use")
                Spacer()
            }.onTapGesture {
                UIApplication.shared.open(URL(string: "https://tkgstrator.work/?p=28236")!)
            }
            HStack {
                Text("X-Product Version")
                Spacer()
                Text("\(user.isVersion)")
            }.onLongPressGesture { user.isPurchase.toggle() }
            HStack {
                Text("Version")
                Spacer()
                Text("\(version)")
            }.onLongPressGesture { isImported() }
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private func isImported() {
        user.isImported.toggle() // 反転させる
        guard let salmonia = realm.objects(SalmoniaUserRealm.self).first else { return }
        realm.beginWrite()
        salmonia.isImported = user.isImported
        try? realm.commitWrite()
    }
    
    private var UserSection: some View {
        Section(header: Text("Status")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            NavigationLink(destination: UserListView()) { Text("Sign in") }
            //            NavigationLink(destination: CrewListView().environmentObject(SalmoniaUserCore())) { Text("Fav Crews") }
            HStack {
                Text("laravel session")
                Spacer()
                Text("\((user.api_token != nil ? "Registered" : "Unregistered").localized)")
            }
            HStack {
                Text("User type")
                Spacer()
                Text("\((user.isPurchase ? "Pro user" : "Free user").localized)")
            }
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var UserStatus: some View {
        Section(header: Text("Feature")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            HStack {
                NavigationLink(destination: SyncUserData()) {
                    HStack {
                        Text("Update Username")
                        Spacer()
                    }
                }
            }
            if !user.isImported {
                NavigationLink(destination: ImportResultView()) {
                    HStack {
                        Text("Import Results")
                        Spacer()
                    }
                }
            }
            NavigationLink(destination: UnlockFeatureView()) {
                HStack {
                    Text("Unlock")
                    Spacer()
                }
            }
        }
        .modifier(Splatfont2(size: 16))
    }
    
    // 通知を出す
    func notification(title: Notification, message: Notification) {
        
        let content = UNMutableNotificationContent()
        content.title = title.localizedDescription.localized
        content.body = message.localizedDescription.localized
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // Salmon Run Recordsからデータをとってくる（重い）
    func updateSalmonRunRecords() {
        AF.request("https://script.google.com/macros/s/AKfycbyD9cZfl81ZaaSnDcT4oc3APSfQ8L6CgwMqsRtvbqT3KF7Irpk/exec", method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch (response.result) {
                case .success(let value):
                    print(JSON(value)) // 全体のリザルトであることに注意
                case .failure:
                    break
                }
        }
    }
    
    // ユーザ名を同期する
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
                } catch (let error) {
                    print(error)
                }
            }
            
            try? realm.commitWrite()
            notification(title: .success, message: .update)
        }
    }
    
}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
