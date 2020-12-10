//
//  SFSafariView.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-10.
//

import SwiftUI
import UIKit
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController

    var url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SFSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
    }
}
