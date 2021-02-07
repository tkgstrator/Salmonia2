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
import GoogleMobileAds

let realm = try! Realm()

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let isUnlock = [false, false, false, false, false, false]
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
        GADMobileAds.sharedInstance().start(completionHandler: nil) // Google Adsense
        realmMigration() // データベースのマイグレーション
        initSwiftyStoreKit() // StoreKitの初期化
        try? getXProductVersion() // プロダクトIDを更新
        try? getFutureRotation() // 将来のシフトを取得
        FirebaseApp.configure() // Firebaseの設定
        registerForPushNotifications() // Push通知
        retrieveProduct()
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
    
    // データベースのマイグレーション
    func realmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 25,
            migrationBlock: { [self] migration, oldSchemaVersion in
                print("MIGRATION", oldSchemaVersion)
                // 毎回再読込する
                if (oldSchemaVersion < 21) {
                    migration.enumerateObjects(ofType: FeatureProductRealm.className()) { oldObject, newObject in
                        migration.delete(newObject!)
                    }
                }
                if (oldSchemaVersion < 24) {
                    migration.enumerateObjects(ofType: SalmoniaUserRealm.className()) { _, newObject in
                        newObject!["isUnlock"] = isUnlock
                    }
                }
            })
        Realm.Configuration.defaultConfiguration = config
    }
    
    // 課金システムを搭載
    func initSwiftyStoreKit() {
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
                    break
                }
            }
        }
    }
    
    // アプリの課金情報を取得する
    func retrieveProduct() {
        let productIds = ["work.tkgstrator.Salmonia2.Accounts", "work.tkgstrator.Salmonia2.Consumable.Donation", "work.tkgstrator.Salmonia2.MonthlyPass"]
        autoreleasepool {
            guard let realm = try? Realm() else { return }
            for productId in productIds {
                SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
                    if let product = result.retrievedProducts.first {
                        let value: [String: String] = [
                            "productIdentifier": productId,
                            "localizedTitle": product.localizedTitle,
                            "localizedDescription": product.localizedDescription,
                            "localizedPrice": product.localizedPrice!
                        ]
                        print(product.localizedTitle)
                        realm.beginWrite()
                        realm.create(FeatureProductRealm.self, value: value, update: .all)
                        try? realm.commitWrite()
                    }
                    else if let invalidProductId = result.invalidProductIDs.first {
                        print("Invalid product identifier: \(invalidProductId)")
                    }
                    else {
                        print("Error: \(result.error)")
                    }
                }
            }
        }
    }
    
    func getXProductVersion() throws -> () {
        let realm = try Realm()
        // Salmoniaユーザがいなければ作成
        let users = realm.objects(SalmoniaUserRealm.self)
        if users.isEmpty {
            realm.beginWrite()
            let user = SalmoniaUserRealm(isUnlock: isUnlock)
            realm.add(user)
            try? realm.commitWrite()
        }
        
        let url = "https://salmonia2-api.netlify.app/version.json"
        // X-Product Versionを取得する
        AF.request(url, method: .get)
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
    
    func getFutureRotation() throws -> () {
        let realm = try Realm()
        // Salmoniaユーザがいなければ作成
        let users = realm.objects(SalmoniaUserRealm.self)
        if users.isEmpty {
            realm.beginWrite()
            let user = SalmoniaUserRealm(isUnlock: isUnlock)
            realm.add(user)
            try? realm.commitWrite()
        }
        
        let url = "https://salmonia2-api.netlify.app/coop.json"
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
                case .failure(let error):
                    print(error)
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
