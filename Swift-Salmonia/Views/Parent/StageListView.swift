//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI

struct StageListView: View {
    var body: some View {
        VStack {
            HStack {
                ForEach(Range(1...3)) { _ in
                    StageStack()
                }
            }
            HStack {
                ForEach(Range(1...2)) { _ in
                    StageStack()
                }
            }
        }
    }
}

private struct StageStack: View {
    var body: some View {
        NavigationLink(destination: StageRecordsView()) {
            Text("Stage")
        }
    }
}

struct StageListView_Previews: PreviewProvider {
    static var previews: some View {
        StageListView()
    }
}
