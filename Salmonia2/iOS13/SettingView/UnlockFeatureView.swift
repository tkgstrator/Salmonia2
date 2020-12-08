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
    
    var body: some View {
        List {
            Section(header: Text("Free")
                        .font(.custom("Splatfont", size: 18))
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
                Toggle(isOn: $user.isUnlock[3]) {
                    Text("Hidden Feature")
                }.disabled(true)
            }
            Section(header: Text("Paid")
                        .font(.custom("Splatfont", size: 18))
                        .foregroundColor(.cOrange)) {
                HStack {
                    VStack(alignment: .leading ){
                        Text("Multiple Accounts")
                        Text("Enable multiple accounts").modifier(Splatfont(size: 14))
                    }
                    Spacer()
                    if user.isPurchase == false {
                        MultipleAccounts
                            .onTapGesture {
                                callStoreKit("work.tkgstrator.Salmonia2.MultipleAccounts")
                            }
                    } else {
                        MultipleAccountsPurchased
                    }
                    
                }.frame(height: 60)
                HStack {
                    VStack(alignment: .leading ){
                        Text("Donation")
                        Text("Donate to the developer").modifier(Splatfont(size: 14))
                    }
                    Spacer()
                    Text("$3.99")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .onTapGesture {
                            callStoreKit("work.tkgstrator.Salmonia2.Consumable.Donation")
                        }
                }.frame(height: 60)
                HStack {
                    VStack(alignment: .leading ){
                        Text("Monthly Pass")
                        Text("Donate to the developer").modifier(Splatfont(size: 14))
                    }
                    Spacer()
                    Text("$3.99")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .onTapGesture {
                            callStoreKit("work.tkgstrator.Salmonia2.MonthlyPass")
                        }
                }.frame(height: 60)
            }
        }
        .modifier(Splatfont(size: 18))
        .navigationBarTitle("Feature")
        .onDisappear() {
            print(user.isUnlock)
            user.updateUnlock(user.isUnlock)
        }
    }
    
    private var MultipleAccounts: some View {
        Text("$3.99")
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 3)
            )
    }
    
    private var MultipleAccountsPurchased: some View {
        Text("Paid")
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.cGray, lineWidth: 3)
            )
            .foregroundColor(Color.cGray)
    }
    
    func callStoreKit(_ product: String) {
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                switch purchase.productId {
                case "work.tkgstrator.Salmonia2.MultipleAccounts":
                    guard let realm = try? Realm() else { return }
                    let user = realm.objects(SalmoniaUserRealm.self)
                    try! realm.write {
                        user.setValue(true, forKey: "isPurchase")
                    }
                case "work.tkgstrator.Salmonia2.Consumable":
                    guard let realm = try? Realm() else { return }
                    let user = realm.objects(SalmoniaUserRealm.self)
                    try! realm.write {
                        user.setValue(true, forKey: "isPurchase")
                    }
                case "work.tkgstrator.Salmonia2.MonthlyPass":
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
}

struct UnlockFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        UnlockFeatureView()
    }
}
