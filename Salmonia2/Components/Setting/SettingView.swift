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
    @EnvironmentObject var main: MainCore
    // 0はSalmon Stats
    // 1は使い方ページ
    // 2はLanPlayについて
    // 3はプライバシーポリシー
    // 4は設定削除確認
    @State var isPresented: [Bool] = [false, false, false, false, false]
    @State var isAlert: [Bool] = [false, false] // 手動設定のアラート用
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
        .navigationTitle("TITLE_SETTINGS")
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
        Section(header: Text("HEADER_APPLICATION")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange))
        {
            BSafariView(isPresented: $isPresented[1], title: "SETTING_TUTORIAL", url: "https://tkgstrator.work/?p=28236")
            BSafariView(isPresented: $isPresented[2], title: "SETTING_PRIVACY", url: "https://tkgstrator.work/?page_id=25126")
            HStack {
                Button(action: { isAlert[1].toggle() }) {
                    Text("SETTING_DELETE_MAIN")
                }
                .alert(isPresented: $isAlert[1]) {
                    Alert(
                        title: Text("ALERT_TITLE_DELETE"),
                        message: Text("ALERT_TEXT_DELETE"),
                        primaryButton: .default(Text("BTN_CANCEL")),
                        secondaryButton: .destructive(Text("BTN_CONFIRM"), action: {
                            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                            autoreleasepool {
                                realm.beginWrite()
                                realm.delete(realm.objects(MainRealm.self))
                                realm.delete(realm.objects(UserInfoRealm.self))
                                realm.delete(realm.objects(CoopResultsRealm.self))
                                realm.delete(realm.objects(WaveDetailRealm.self))
                                try? realm.commitWrite()
                            }
                        }
                        )
                    )
                }
            }
            HStack {
                Text("SETTING_XPRODUCT_VERSION")
                Spacer()
                Text("\(main.verion)")
            }
            
            HStack {
                Text("SETTING_APP_VERSION")
                Spacer()
                Text("\(version)")
            }
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var LanPlayStatus: some View {
        Section(header: Text("HEADER_LANPLAY")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            BSafariView(isPresented: $isPresented[3], title: "SETTING_WHAT_LANPLAY", url: "https://tkgstrator.work/?p=5240")
            HStack {
                Text("SETTING_LANPLAY_ONLINE")
                Spacer()
                Text("\(online.value)")
            }
            HStack {
                Text("SETTING_LANPLAY_IDLE")
                Spacer()
                Text("\(idle.value)")
            }
            HStack {
                Text("SETTING_LANPLAY_VERSION")
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
        Section(header: Text("HEADER_SIGN_IN")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            NavigationLink(destination: UserListView()) { Text("SETTING_SPLATNET2") }
            BSalmonStatsLoginView(isPresented: $isPresented[0])
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var UserSection: some View {
        Section(header: Text("HEADER_STATUS")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            // TODO: 課金情報ステータス直せ
            HStack {
                Text("SETTING_LARAVEL_SESSION")
                Spacer()
                Text("\((main.apiToken != nil ? "SETTING_REGISTERED" : "SETTING_UNREGISTERED").localized)")
            }
            HStack {
                Text("SETTING_USER_TYPE")
                Spacer()
                Text("\((main.userType ? "SETTING_UNLIMITED" : "SETTING_LIMITED").localized)")
            }
            HStack {
                Button("SETTING_UPDATE_TOKEN") {
                    isPresented[4].toggle()
                }
                TextFieldAlertView(
                    text: $iksm_session,
                    isShowingAlert: $isPresented[4],
                    placeholder: "",
                    isSecureTextEntry: true,
                    title: "SETTING_MANUAL_UPDATE".localized,
                    message: "SETTING_INPUT_TOKEN".localized,
                    leftButtonTitle: "BTN_CANCEL",
                    rightButtonTitle: "BTN_CONFIRM",
                    leftButtonAction: nil, rightButtonAction: {
                        do {
                            let nsaid = try SplatNet2.getPlayerId(iksm_session)
                            guard let user = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid).first else { throw APPError.empty }
                            realm.beginWrite()
                            user.iksm_session = iksm_session
                            try realm.commitWrite()
                            isAlert[0].toggle()
                            message = "MSG_UPDATE_SUCC"
                        } catch(let error) {
                            isAlert[0].toggle()
                            message = error.localizedDescription
                        }
                    })
                    .alert(isPresented: $isAlert[0]) {
                        Alert(title: Text(message.localized))
                    }
            }
            .disabled(!main.userType)
        }
        .modifier(Splatfont2(size: 16))
    }
    
    private var UserStatus: some View {
        Section(header: Text("HEADER_FEATURE")
                    .modifier(Splatfont2(size: 16))
                    .foregroundColor(.cOrange)) {
            HStack {
                NavigationLink(destination: SyncUserData()) {
                    HStack {
                        Text("SETTING_UPDATE_NAME")
                        Spacer()
                    }
                }
            }
            // TODO: 取り込み機能直せ
            NavigationLink(destination: ImportResultView()) {
                HStack {
                    Text("SETTING_IMPORT_RESULTS")
                    Spacer()
                }
            }
            .disabled(!main.userType)
            NavigationLink(destination: UnlockFeatureView()) {
                HStack {
                    Text("SETTING_UNLOCK")
                    Spacer()
                }
            }
        }
        .modifier(Splatfont2(size: 16))
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
