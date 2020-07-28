//
//  SceneDelegate.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-20.
//  Copyright © 2020 devonly. All rights reserved.
//

import UIKit
import SwiftUI
import SafariServices
import RealmSwift

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
//        guard let _ = (scene as? UIWindowScene) else { return }
//        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        guard let url = URLContexts.first?.url else { return }
        guard let session_token_code = url.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
        let session_token_code_verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak"
        
        // この辺でモーダルを閉じたい
        // session_tokenの取得
        SplatNet2.getSessionToken(session_token_code: session_token_code, session_token_code_verifier: session_token_code_verifier) { response in
            let session_token = response["session_token"].stringValue
            print("SESSION TOKEN", session_token)
            // access_tokenの取得
            SplatNet2.getAccessToken(session_token: session_token) { response in
                let access_token = response["access_token"].stringValue
                print("ACCESS TOKEN", access_token)
                // fの取得
                SplatNet2.callFlapgAPI(access_token: access_token, type: "nso") { response in
                    // splatoon_tokenの取得
                    SplatNet2.getSplatoonToken(result: response) { response in
                        let splatoon_token = response["splatoon_token"].stringValue
                        print("SPLATOON TOKEN", splatoon_token)
                        let username = response["user"]["name"].stringValue
                        let imageUri = response["user"]["image"].stringValue
                        // fの取得
                        SplatNet2.callFlapgAPI(access_token: splatoon_token, type: "app") { response in
                            // splatoon_access_tokenの取得
                            SplatNet2.getSplatoonAccessToken(result: response, splatoon_token: splatoon_token) { response in
                                let splatoon_access_token = response["splatoon_access_token"].stringValue
                                print("SPLATOON ACCESS TOKEN", splatoon_access_token)
                                SplatNet2.getIksmSession(splatoon_access_token: splatoon_access_token) { response in
                                    let iksm_session = response["iksm_session"].stringValue
                                    let nsaid = response["nsaid"].stringValue
                                    print("IKSM SESSION", iksm_session)
                            
                                    // Realmインスタンスの呼び出し
                                    guard let realm = try? Realm() else { return }
                                    let userinfo = UserInfoRealm()
                                    
                                    userinfo.name = username
                                    userinfo.image = imageUri
                                    userinfo.nsaid = nsaid
                                    userinfo.iksm_session = iksm_session
                                    userinfo.session_token = session_token

                                    do {
                                        try realm.write {
                                            realm.add(userinfo, update: .all)
                                        }
                                    } catch {
                                        print("Realm Write Error")
                                    }
                                    // 処理が完了したのでアラート表示したい
                                    print("Write New Record")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

