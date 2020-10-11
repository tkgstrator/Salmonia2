//
//  SceneDelegate.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import UIKit
import SwiftUI
import RealmSwift
import SplatNet2
import SwiftyJSON

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)
    {
        func notification(title: String, body: String) {
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
        
        guard let url = URLContexts.first?.url else { return }
        guard let session_token_code = url.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
        let session_token_code_verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak"
        
        guard let version = try? Realm().objects(SalmoniaUserRealm.self).first?.isVersion else { return }

        DispatchQueue(label: "Login").async {
            do {
                var response: JSON = JSON()
                response = try SplatNet2.getSessionToken(session_token_code, session_token_code_verifier)
                let session_token = response["session_token"].stringValue
                response = try SplatNet2.genIksmSession(session_token, version: version)
                guard let thumbnail_url = response["user"]["thumbnail_url"].string else { throw APIError.Response("1004", "Iksm Session Error") }
                guard let nickname = response["user"]["nickname"].string else { throw APIError.Response("1004", "Iksm Session Error") }
                guard let iksm_session = response["iksm_session"].string else { throw APIError.Response("1004", "Iksm Session Error") }
                guard let nsaid = response["nsaid"].string else { throw APIError.Response("1004", "Iksm Session Error") }
                guard let realm = try? Realm() else { throw APIError.Response("0001", "Realm DB Error")}
                try? realm.write {
                    let account = realm.objects(UserInfoRealm.self).filter("nsaid=%@", nsaid)
                    switch account.isEmpty {
                    case true: // 新規作成
                        guard let _user: SalmoniaUserRealm = realm.objects(SalmoniaUserRealm.self).first else { return }
                        let _account: [String: Any?] = ["nsaid": nsaid, "name": nickname, "image": thumbnail_url, "iksm_session": iksm_session, "session_token": session_token, "isActive": _user.account.isEmpty]
                        let account: UserInfoRealm = UserInfoRealm(value: _account)
                        realm.add(account, update: .modified)
                        _user.account.append(account)
                        notification(title: "New Login", body: "Success to add new NSO account.")
                    case false: // 再ログイン（アップデート）
                        guard let session_token = account.first?.session_token else { return }
                        account.setValue(iksm_session, forKey: "iksm_session")
                        account.setValue(session_token, forKey: "session_token")
                        account.setValue(thumbnail_url, forKey: "image")
                        account.setValue(nickname, forKey: "name")
                        notification(title: "User Info Update", body: "Success to update.")
                    }
                }
            } catch APIError.Response(let title, let message) {
                notification(title: title, body: message)
            } catch (let error){
                notification(title: "9999", body: error.localizedDescription)
            }
        }
    }
}
