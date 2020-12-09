//
//  FeatureProductCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift
import StoreKit
import SwiftyStoreKit

class FeatureProductCore: ObservableObject {
    private var token: NotificationToken?

    @Published var features: [Product] = []
    
    init() {
        // 変更があるたびに再読込するだけ
        token = realm.objects(FeatureProductRealm.self).observe { [self] _ in
            let products = realm.objects(FeatureProductRealm.self)
            features = [] // 一度リストを空っぽにする
            for product in products {
                features.append(Product(product))
            }
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
    struct Product: Hashable {
        var localizedPrice: String?
        var productIdentifier: String
        var localizedDescription: String
        var localizedTitle: String
        
        init(_ product: FeatureProductRealm) {
            productIdentifier = product.productIdentifier
            localizedTitle = product.localizedTitle
            localizedDescription = product.localizedDescription
            localizedPrice = product.localizedPrice
        }
    }
}
