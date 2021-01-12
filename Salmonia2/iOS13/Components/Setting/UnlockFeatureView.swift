//  UnlockFeatureView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-24.
//

import SwiftUI
import RealmSwift
import SwiftyStoreKit

struct UnlockFeatureView: View {
    @EnvironmentObject var user: SalmoniaUserCore
    @EnvironmentObject var paid: FeatureProductCore
    
    init() {
        retrieveProduct()
    }
    
    var body: some View {
        List {
            Section(header: Text("Free")
                        .font(.custom("Splatfont2", size: 16))
                        .foregroundColor(.cOrange)) {
                Toggle(isOn: $user.isUnlock[0]) {
                    Text("Future Rotation")
                }
                Toggle(isOn: $user.isUnlock[1]) {
                    Text("Grizzco Weapons")
                }
                Toggle(isOn: $user.isUnlock[2]) {
                    Text("Force Update")
                }
//                Toggle(isOn: $user.isUnlock[3]) {
//                    Text("Login in Safari")
//                }
                Toggle(isOn: $user.isUnlock[4]) {
                    Text("Disable Ads")
                }
            }
            Section(header: Text("Paid")
                        .font(.custom("Splatfont2", size: 16))
                        .foregroundColor(.cOrange)) {
                ForEach(paid.features.reversed(), id:\.self) { feature in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(feature.localizedTitle.localized)
                                Text(feature.localizedPrice!.localized)
                                    .modifier(Splatfont2(size: 16))
                            }
                            Text(feature.localizedDescription.localized)
                                .modifier(Splatfont2(size: 14))
                        }
                        Spacer()
                        if feature.productIdentifier == "work.tkgstrator.Salmonia2.MonthlyPass" {
                            PayButton(title: "Subscribe".localized, product: feature.productIdentifier)
                        } else {
                            PayButton(title: "Purchase".localized, product: feature.productIdentifier)
                        }
                    }.frame(height: 60)
                }
            }
        }
        .modifier(Splatfont2(size: 16))
        .navigationBarTitle("Feature")
        .onDisappear() {
            user.updateUnlock(user.isUnlock)
        }
    }
   
    func retrieveProduct() {
        let productIds = ["work.tkgstrator.Salmonia2.MultipleAccounts", "work.tkgstrator.Salmonia2.Consumable.Donation", "work.tkgstrator.Salmonia2.MonthlyPass"]
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
    
    struct PayButton: View {
        var title: String = ""
        var product: String = ""
        
        var body: some View {
            Button(title) {
                callStoreKit(product)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 3)
            )
        }
        
        func callStoreKit(_ product: String) -> Void {
            SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                switch result {
                case .success(let purchase):
                    guard let realm = try? Realm() else { return }
                    let user = realm.objects(SalmoniaUserRealm.self)
                    switch purchase.productId {
                    case "work.tkgstrator.Salmonia2.MultipleAccounts":
                        try! realm.write {
                            user.setValue(true, forKey: "isPurchase")
                        }
                    case "work.tkgstrator.Salmonia2.Consumable":
                        try! realm.write {
                            user.setValue(true, forKey: "isPurchase")
                        }
                    case "work.tkgstrator.Salmonia2.MonthlyPass":
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
    }
}

struct UnlockFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockFeatureView()
    }
}
