//
//  AppDelegate.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-27.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftyStoreKit
import UserNotifications
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                self.getNotificationSettings()
            }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler:@escaping (UIBackgroundFetchResult) -> Void) {
        
        let state : UIApplication.State = application.applicationState
        if (state == .inactive || state == .background) {
            // go to screen relevant to Notification content
            print("background")
        } else {
            // App is in UIApplicationStateActive (running in foreground)
            print("foreground")
            // showLocalNotification()
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        realmMigration()
        initSwiftyStoreKit()
        try? getXProduceVersion()
        FirebaseApp.configure()
        registerForPushNotifications()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func realmMigration() {
        // データベースのマイグレーション
        var config = Realm.Configuration(
            schemaVersion: 15,
            migrationBlock: { migration, oldSchemaVersion in
                print(oldSchemaVersion, migration)
                if (oldSchemaVersion < 10) {
                    migration.enumerateObjects(ofType: SalmoniaUserRealm.className()) { _, newObject in
                        newObject!["isUnlock"] = [false, false, false, false]
                    }
                }
                if (oldSchemaVersion < 15) {
                    migration.deleteData(forType: "CoopShiftRealm")
                }
            })
        Realm.Configuration.defaultConfiguration = config
        config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
    }
    
    func initSwiftyStoreKit() {
        // 課金システムを搭載
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    print("ERROR")
                }
            }
        }
    }
    
    func getXProduceVersion() throws -> () {
        let realm = try Realm()
        // Salmoniaユーザがいなければ作成
        let users = realm.objects(SalmoniaUserRealm.self)
        if users.isEmpty {
            realm.beginWrite()
            let user = SalmoniaUserRealm(isUnlock: [false, false, false])
            realm.add(user)
            try? realm.commitWrite()
        }
        
        let url = "https://script.google.com/macros/s/AKfycbyzVfi2BXni9V439fFtRAqQSjXzNxiUSKFFNEjQ7VNNQlCfcCXt/exec"
        // シフト情報を取得する
        AF.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    realm.beginWrite()
                    for (_, shift) in JSON(value) {
                        let value = shift.dictionaryObject
                        realm.create(CoopShiftRealm.self, value: value as Any, update: .all)
                    }
                    try? realm.commitWrite()
                case .failure:
                    break
                }
            }
        // X-Product Versionを取得する
        AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON() { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    realm.beginWrite()
                    realm.objects(SalmoniaUserRealm.self).first?.isVersion = json["version"].stringValue
                    try? realm.commitWrite()
                case .failure:
                    break
                }
            }
    }
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
//    {
//        // アプリ起動時も通知を行う
//        completionHandler([ .badge, .sound, .alert ])
//    }
//}
