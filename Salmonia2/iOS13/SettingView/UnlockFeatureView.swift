//
//  UnlockFeatureView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-24.
//

import SwiftUI
import RealmSwift
import SwiftyStoreKit

struct UnlockFeatureView: View {
    
    func callStoreKit(_ product: String) {
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                switch purchase.productId {
                case "work.tkgstrator.Salmonia2.isActive":
                    guard let realm = try? Realm() else { return }
                    let user = realm.objects(SalmoniaUserRealm.self)
                    try! realm.write {
                        user.setValue(true, forKey: "isPurchase")
                    }
                default:
                    break
                }
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    var body: some View {
        List {
            HStack {
                Text("Enable multiple account")
                Spacer()
                Text("$3.99")
            }.onTapGesture {
                callStoreKit("work.tkgstrator.Salmonia2.isActive")
            }
            HStack {
                Text("Give Dr.Pepper")
                Spacer()
                Text("$3.99")
            }.onTapGesture {
                callStoreKit("work.tkgstrator.Salmonia2.Asphalt")
            }
            HStack {
                Text("Give Dr.Pepper(Monthly)")
                Spacer()
                Text("$3.99")
            }.onTapGesture {
                callStoreKit("work.tkgstrator.Salmonia2.DrPepper")
            }
        }
        .modifier(Splatfont(size: 18))
        .navigationBarTitle("Feature")
    }
    
}

struct UnlockFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockFeatureView()
    }
}
