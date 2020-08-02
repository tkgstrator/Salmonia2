//
//  OverView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import URLImage

struct StageStack: View {
    private var stage_name: String = ""
    private var imageUri: String = ""
    private var records: StageRecords = StageRecords()
    
    init(stage: String, value: StageRecords) {
        stage_name = stage
        records = value
        guard let url = Enum().Stage.filter({$0.name == stage}).first?.url else { return }
        imageUri = "https://app.splatoon2.nintendo.net/images/coop_stage/" + url
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: StageRecordsView(name: stage_name, value: records.data)) {
                URLImage(URL(string: imageUri)!, content: {$0.image.renderingMode(.original).resizable().aspectRatio(contentMode: .fill)})
                    .frame(width: 110, height: 60)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
            HStack {
                Text(records.grade_point.string).foregroundColor(.red)
                Text(records.team_golden_eggs.string).foregroundColor(.yellow)
            }
            .font(.custom("Splatfont2", size: 18))
            .padding(.top, 0)
        }
    }
}


struct PlayerOverView: View {
    private var records: [StageRecords] = []
    private var overview: PlayerOverview = PlayerOverview() //くっそ間違えやすいから名前変えたい
    
    init(data: UserInformation) {
        records = data.records
        overview = data.overview
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                PlayerOverViewColumn(title: "Jobs", value: overview.job_count)
                Spacer()
                VStack(spacing: 0) {
                    Text("Eggs").frame(height: 20).padding(2)
                    HStack {
                        Text(overview.golden_ikura_total.string).foregroundColor(.yellow)
                        Text("/")
                        Text(overview.ikura_total.string).foregroundColor(.red)
                    }
                    .frame(height: 20).padding(2).foregroundColor(.yellow)
                }.font(.custom("Splatfont2", size: 20)).padding(0).frame(alignment: .center)
                Spacer()
                PlayerOverViewColumn(title: "Points", value: overview.kuma_point_total)
            }.frame(maxWidth: .infinity)
            FutureShiftView()
            HStack {
                StageStack(stage: "Spawning Grounds", value: records[0])
                Spacer()
                StageStack(stage: "Marooner's Bay", value: records[1])
                Spacer()
                StageStack(stage: "Lost Outpost", value: records[2])
            }
            HStack {
                StageStack(stage: "Salmonid Smokeyard", value: records[3])
                Spacer()
                StageStack(stage: "Ruins of Ark Polaris", value: records[4])
            }
        }
    }
}

struct PlayerOverViewColumn: View {
    
    private var title: String
    private var value: String
    
    init(title: String, value: Any?) {
        self.title = title
        self.value = value.string
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title).frame(height: 20).padding(2)
            Text(value).frame(height: 20).padding(2)
        }.font(.custom("Splatfont2", size: 20)).padding(0).frame(alignment: .center)
    }
}

//struct OverView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverView()
//    }
//}
