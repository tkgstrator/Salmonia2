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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // パスを表示
        print(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
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
        
        do {
            let realm = try Realm()
            let url = "https://gist.githubusercontent.com/tkgstrator/adcea132ae2fea4bd646a6d062279056/raw/11f588d1f0be667ee9296c6d3ebe201710f2df05/FutureShift.json"
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["text/plain"])
                .responseJSON() { response in
                    switch response.result {
                    case .success(let value):
                        realm.beginWrite()
                        for (_, shift) in JSON(value) {
                            let value = shift.dictionaryObject
                            realm.create(FutureShiftRealm.self, value: value as Any, update: .all)
                        }
                        try? realm.commitWrite()
                    case .failure:
                        break
                    }
                }
        } catch {
            return false
        }
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
    
    
}

