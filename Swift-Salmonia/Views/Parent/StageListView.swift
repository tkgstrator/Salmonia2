//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import URLImage

struct StageListView: View {
    @ObservedObject var records = UserResultsCore()
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Stage Records")
                .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatoon1", size: 20))
            ForEach(Range(0...4)) { stage in
                HStack(alignment: .top) {
                    Group {
                        NavigationLink(destination: StageRecordsView()) {
                            URLImage(URL(string: Stage(id: stage + 5000))!, content: {$0.image.resizable()})
                                .frame(width: 112, height: 63)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                    }
                    Group {
                        VStack(spacing: 5) {
                            Text(Stage(name: stage + 5000))
                                .frame(height: 22).frame(maxWidth: .infinity)
                                .font(.custom("Splatoon1", size: 20))
                            HStack {
                                URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                                    .frame(width: 20, height: 20)
                                Text("999").frame(height: 22)
                            }
                        }
                    }
                    .font(.custom("Splatoon1", size: 18))
                    .frame(height: 80)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct StageStack: View {
    var body: some View {
        NavigationLink(destination: StageRecordsView()) {
            URLImage(URL(string: Stage(id: 5000))!, content: {$0.image.resizable()})
                .frame(width: 112, height: 63)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }.buttonStyle(PlainButtonStyle())
    }
}

struct StageListView_Previews: PreviewProvider {
    static var previews: some View {
        StageListView()
    }
}
