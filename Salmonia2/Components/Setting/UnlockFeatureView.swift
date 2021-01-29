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
    @State var isVisible: Bool = false
    @State var mLog: String = ""
    @State var mTitle: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Free")
                        .font(.custom("Splatfont2", size: 16))
                        .foregroundColor(.cOrange)) {
                Toggle("Future Rotation", isOn: $user.isUnlock[0])
                Toggle("Grizzco Weapons", isOn: $user.isUnlock[1])
                Toggle("Force Update", isOn: $user.isUnlock[2])
                Toggle("Disable Ads", isOn: $user.isUnlock[3])
                Toggle("Legacy Style", isOn: $user.isUnlock[4])
            }
            Section(header: Text("Paid")
                        .font(.custom("Splatfont2", size: 16))
                        .foregroundColor(.cOrange)) {
                ForEach(Array(paid.features.reversed()), id:\.self) { feature in
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
                        PayButton(isValid: feature.isValid, isSubscribed: false, product: feature.productIdentifier)
                    }.frame(height: 60)
                }
            }
            Section(header: Text("Option")
                        .font(.custom("Splatfont2", size: 16))
                        .foregroundColor(.cOrange)) {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Restore")
                                .modifier(Splatfont2(size: 16))
                        }
                        Text("Restore purchased product")
                            .modifier(Splatfont2(size: 14))
                    }
                    Spacer()
                    RestoreButton
                }.frame(height: 60)
            }
        }
        .modifier(Splatfont2(size: 16))
        .navigationBarTitle("Feature")
        .alert(isPresented: $isVisible) {
            Alert(title: Text(mTitle.localized), message: Text(mLog.localized))
        }
        .onDisappear() {
            user.updateUnlock(user.isUnlock) // アンロックした情報を書き込む
        }
    }
    
    func restoreStoreKit() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                mTitle = "Failed"
                mLog = "Restore Failed"
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                mLog = "Restore Success"
                for product in results.restoredPurchases {
                    print(product.productId)
                    do {
                        guard let data = realm.objects(FeatureProductRealm.self).filter("productIdentifier=%@", product.productId).first else { throw SKError.invalid }
                        guard let user = realm.objects(SalmoniaUserRealm.self).first else { throw SKError.unknown}
                        realm.beginWrite()
                        data.isValid = false
                        user.isPurchase = false
                        try? realm.commitWrite()
                        mTitle = "Success"
                        mLog = "Restore Success"
                        print("Success")
                    } catch(let error) {
                        mTitle = "Failed"
                        mLog = error.localizedDescription
                        print("Failed")
                    }
                }
                print("Restore Success: \(results.restoredPurchases)")
            } else {
                mTitle = "Failed"
                mLog = "Nothing to Restore"
                print("Nothing to Restore")
            }
            isVisible = true
        }
    }

    
    var RestoreButton: some View {
        Button("Restore") {
            restoreStoreKit()
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white, lineWidth: 3)
        )
    }
    
    struct PayButton: View {
        var isValid: Bool
        var isSubscribed: Bool
        var product: String
        
        var body: some View {
            Button(!isSubscribed ? isValid ? "Purchased" : "Purchase" : isValid ? "Subscribed" : "Subscribe") {
                callStoreKit(product)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 3)
            )
            .disabled(isValid)
        }
        
        func callStoreKit(_ product: String) -> () {
            SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                switch result {
                case .success(let product):
                    print("Purchase Success: \(product)")
                    SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                        switch result {
                        case .success(let receipt):
                            let encryptedReceipt = receipt.base64EncodedString(options: [])
                            print("Fetch receipt success:\n\(encryptedReceipt)")
                            // 購入処理をここに書く
                            // 購入したら強制的にユーザタイプを変更する（まあこれでいいや）
                            guard let data = realm.objects(FeatureProductRealm.self).filter("productIdentifier=%@", product.productId).first else { return }
                            guard let user = realm.objects(SalmoniaUserRealm.self).first else { return }
                            realm.beginWrite()
                            data.isValid = true
                            user.isPurchase = true
                            try? realm.commitWrite()
                        case .error(let error):
                            print("Fetch receipt failed: \(error)")
                        }
                    }
                case .error(let error):
                    //                    self.hud.dismiss()
                    switch error.code {
                    case .unknown:
                        print("Unknown error. Please contact support")
                    case .clientInvalid:
                        print("Not allowed to make the payment")
                    case .paymentCancelled:
                        break
                    case .paymentInvalid:
                        print("The purchase identifier was invalid")
                    case .paymentNotAllowed:
                        print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable:
                        print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied:
                        print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed:
                        print("Could not connect to the network")
                    case .cloudServiceRevoked:
                        print("User has revoked permission to use this cloud service")
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
