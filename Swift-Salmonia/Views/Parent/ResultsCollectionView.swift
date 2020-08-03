//
//  ResultsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct ResultsCollectionView: View {
    var body: some View {
        List {
            ForEach(Range(1...5)) { _ in
                NavigationLink(destination: ResultView()) {
                    Text("ResultCollectionView")
                }
            }
        }.navigationBarTitle("Results")
    }
}

struct ResultsCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsCollectionView()
    }
}
