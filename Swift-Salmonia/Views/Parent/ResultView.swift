//
//  ResultView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct ResultView: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    ForEach(Range(1...3)) { _ in
                        ResultWaveView()
                    }
                }
                VStack {
                    ForEach(Range(1...4)) { _ in
                        ResultPlayerView()
                    }
                }
            }
        }
        .navigationBarTitle("Detail")
    }
}


// リザルト表示につかう子コンポーネント
private struct ResultWaveView: View {
    var body: some View {
        Text("WaveView")
    }
}

private struct ResultWaveView_Previews: PreviewProvider {
    static var previews: some View {
        ResultWaveView()
    }
}

private struct ResultPlayerView: View {
    var body: some View {
        NavigationLink(destination: SalmonStatsView()) {
            Text("ResultPlayerView")
        }
    }
}

private struct ResultPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        ResultPlayerView()
    }
}


struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
