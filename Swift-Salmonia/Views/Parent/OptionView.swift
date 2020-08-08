//
//  OptionView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-07.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct OptionView: View {
    var body: some View {
        VStack {
            Text("Options")
            .frame(height: 28)
            .foregroundColor(.orange)
            .font(.custom("Splatoon1", size: 20))
            HStack {
                NavigationLink(destination: CrewView()) {
                    Text("Crew Memers")
                        .frame(height: 28)
                }
            }
            .font(.custom("Splatoon1", size: 20))
        }
    }
}

private struct CrewView: View {
    @ObservedObject var players = CrewInfoCore()

    var body: some View {
        List {
            ForEach(players.matchids.indices, id: \.self) { idx in
                HStack {
                    URLImage(URL(string: self.players.matchids[idx].url!)!, content: {$0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                    .frame(width: 60, height: 60)
                    Text("\(self.players.matchids[idx].name!)")
                    Spacer()
                    Text("\(self.players.matchids[idx].match)")
                }
                .font(.custom("Splatoon1", size: 22))
            }
        }
    .navigationBarTitle("Friendly Crew")
        .onAppear() {
        }
    }
}

struct OptionView_Previews: PreviewProvider {
    static var previews: some View {
        OptionView()
    }
}
