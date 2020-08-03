//
//  ResultsCollectionView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-31.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import Combine
import URLImage
import RealmSwift

struct ResultStack: View {
    private var result: ResultCollection
    
    init(data: ResultCollection) {
        result = data
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(result.danger_rate.string + "%").frame(height: 5.vw).padding(0)
                Spacer()
                Group {
                    ForEach(result.weapons, id: \.self) { weapon in
                        URLImage(URL(string: weapon.weapon)!, content: {$0.image.resizable().frame(width: 10.vw, height: 10.vw)
                        })
                    }
                }
            }.frame(height: 12.vw)
            HStack {
                Group {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: {$0.image.resizable()})
                        .frame(width: 5.vw, height: 5.vw)
                    Text(result.golden_eggs.string).frame(width: 10.vw)
                    Spacer()
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/78f61aacb1fbb50f345cdf3016aa309e.png")!, content: {$0.image.resizable()})
                        .frame(width: 5.vw, height: 5.vw)
                    Text(result.power_eggs.string).frame(width: 12.vw)
                    Spacer()
                }
                Group {
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/c003ffe0a5580e4c8b1bc9df1e0a30d2.png")!, content: {$0.image.resizable()})
                        .frame(width: 11.5.vw, height: 5.vw)
                    Text("99").frame(width: 8.vw)
                    Spacer()
                    URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/5d447dcfcb3b0c31ffb2efca58a6e799.png")!, content: {$0.image.resizable()})
                        .frame(width: 11.5.vw, height: 5.vw)
                    Text("99").frame(width: 8.vw)
                }
            }
        }
        .padding(2.vw)
        .frame(height: 20.vw)
        .font(.custom("Splatfont2", size: 5.vw))
    }
}

struct ResultsCollectionView: View {
    @ObservedObject var results = ResultsModel()
    
    var body: some View {
        List {
            ForEach(results.data, id: \.self) { result in
                NavigationLink(destination: ResultDetailView(job_id: result.job_id )) {
                    ResultStack(data: result)
                }
            }
        }
        .navigationBarTitle("Results")
    }
}

struct ResultsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsCollectionView()
    }
}
