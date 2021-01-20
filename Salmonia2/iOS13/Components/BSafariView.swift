//
//  SafariView.swift
//  Salmonia2
//
//  Created by devonly on 2021-01-14.
//

import SwiftUI
import BetterSafariView

struct BSafariView: View {
    @Binding var isPresented: Bool
    private var title: String
    private var url: String
    
    init(isPresented: Binding<Bool>, title: String, url: String) {
        self.title = title
        self.url = url
        self._isPresented = isPresented
    }
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            HStack {
                Text(title.localized)
                    .modifier(Splatfont2(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .font(.system(size: 14, weight: .semibold))
            }
            .background(Color.white.opacity(0.0001))
        }
        .safariView(isPresented: $isPresented) {
            SafariView(url: URL(string: url)!, configuration: SafariView.Configuration(
                entersReaderIfAvailable: false,
                barCollapsingEnabled: true
            ))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BSalmonStatsView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            HStack {
                Text("Salmon Stats")
                    .modifier(Splatfont2(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .font(.system(size: 14, weight: .semibold))
            }
            .background(Color.white.opacity(0.0001))
        }
        .buttonStyle(PlainButtonStyle())
        .safariView(isPresented: $isPresented) {
            SafariView(url: URL(string: "https://salmon-stats-api.yuki.games/auth/twitter")!)
        }
    }
}

struct BSalmonStatsLoginView: View {
    @Binding var isPresented: Bool

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            HStack {
                Text("Salmon Stats")
                    .modifier(Splatfont2(size: 16))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(.tertiaryLabel))
                    .font(.system(size: 14, weight: .semibold))
            }
            .background(Color.white.opacity(0.0001))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isPresented) {
            WebBrowser(address: "https://salmon-stats-api.yuki.games/auth/twitter")
        }
    }
}

//struct SafariView_Previews: PreviewProvider {
//    static var previews: some View {
//        SafariView()
//    }
//}
