//
//  AdBannerView.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-10.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct AdBannerViewController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        #if DEBUG
        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        view.adUnitID = "ca-app-pub-7107468397673752/8265355873"
        #endif
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
}

struct AdBannerView: View {
    var body: some View {
        AdBannerViewController()
            .frame(width: 320, height: 50)
    }
}
