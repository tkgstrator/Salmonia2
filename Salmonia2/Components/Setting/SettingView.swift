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
import Alamofire
import UserNotifications
import BetterSafariView

struct SettingView: View {
    @EnvironmentObject var core: UserResultCore
    // 0はSalmon Stats
    // 1は使い方ページ
    // 2はLanPlayについて
    // 3はプライバシーポリシー
    @State var isPresented: [Bool] = [false, false, false, false, false]
    @State var isAlert: Bool = false // 手動設定のアラート用
    @State var message: String = ""
    @State var online: Int? = nil
    @State var idle: Int? = nil
    @State var ver: String? = nil
    @State var iksm_session: String = ""

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    let version: String = "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!))(\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)))"
    
    var body: some View {
        List {
            SignIn
            UserSection
            UserStatus
            LanPlayStatus
            Application
        }
        .navigationBarTitle("Settings")
    }
    
    private func getLanPlayStatus() {
        let url = "http://tkgstrator.work:11451/info"
        AF.request(url, method: .get)
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    online = json["online"].intValue
                    idle = json["idle"].intValue
                    ver = json["version"].stringValue
                case .failure:
                    break
                }
        }
    }
    
    private var Application: some View {
        Section(header: Text("Application")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange))
        {
            BSafariView(isPresented: $isPresented[1], title: "How to use", url: "https://tkgstrator.work/?p=28236")
            BSafariView(isPresented: $isPresented[2], title: "Privacy poricy", url: "https://tkgstrator.work/?page_id=25126")
            HStack {
                Button(action: { UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!) }) {
                    Text("SETTING_DELETE_MAIN")
                }
            }
            HStack {
                Text("X-Product Version")
                Spacer()
//                Text("\(user.isVersion)")
            }
            
            HStack {
                Text("Version")
                Spacer()
                Text("\(version)")
            }
        }
        .modifier(Splatfont2(size: 16))
    }

    private var LanPlayStatus: some View {
        Section(header: Text("LanPlay")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            BSafariView(isPresented: $isPresented[3], title: "What's LanPlay", url: "https://tkgstrator.work/?p=5240")
            HStack {
                Text("Online members")
                Spacer()
                Text("\(online.value)")
            }
            HStack {
                Text("Idle members")
                Spacer()
                Text("\(idle.value)")
            }
            HStack {
                Text("Server version")
                Spacer()
                Text("\(ver.value)")
            }
        }
        .onReceive(timer) { _ in
            getLanPlayStatus()
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var SignIn: some View {
        Section(header: Text("Sign in")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            NavigationLink(destination: UserListView()) { Text("SplatNet2") }
            BSalmonStatsLoginView(isPresented: $isPresented[0])
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var UserSection: some View {
        Section(header: Text("Status")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            // TODO: 課金情報ステータス直せ
            HStack {
                Text("laravel session")
                Spacer()
//                Text("\((user.api_token != nil ? "Registered" : "Unregistered").localized)")
            }
            HStack {
                Text("User type")
                Spacer()
//                Text("\((user.isPurchase ? "Unlimited" : "Limited").localized)")
            }
            HStack {
                Button("Update iksm_session") {
                    isPresented[4].toggle()
                }
                TextFieldAlertView(
                    text: $iksm_session,
                    isShowingAlert: $isPresented[4],
                    placeholder: "",
                    isSecureTextEntry: true,
                    title: "Manual Update".localized,
                    message: "Input iksm_session".localized,
                    leftButtonTitle: "CANCEL",
                    rightButtonTitle: "OK",
                    leftButtonAction: nil, rightButtonAction: {
                        do {
                            let nsaid = try SplatNet2.getPlayerId(iksm_session)
                            guard let user = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid).first else { throw APPError.empty }
                            realm.beginWrite()
                            user.iksm_session = iksm_session
                            try realm.commitWrite()
                            isAlert = true
                            message = "Update Success"
                        } catch(let error) {
                            isAlert = true
                            message = error.localizedDescription
                        }
                    })
                    .alert(isPresented: $isAlert) {
                        Alert(title: Text(message.localized))
                    }
            }
//            .disabled(!user.isPurchase)
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
            // TODO: 取り込み機能直せ
//            if !user.isImported {
//                NavigationLink(destination: ImportResultView()) {
//                    HStack {
//                        Text("Import Results")
//                        Spacer()
//                    }
//                }
//            }
            NavigationLink(destination: UnlockFeatureView()) {
                HStack {
                    Text("Unlock")
                    Spacer()
                }
            }
        }
        .modifier(Splatfont2(size: 16))
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
        }
    }
    
}



//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
//    }
//}
