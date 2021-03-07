//
//  StageRecordView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import URLImage

struct StageRecordView: View {
    var body: some View {
        ForEach(StageType.allCases, id:\.self) { stage in
            ZStack {
                NavigationLink(destination: StageRecordsView().environmentObject(StageRecordCore(stage.stage_id!))) {
                    EmptyView()
                }
                .opacity(0.0)
                HStack {
                    URLImage(url: URL(string: stage.image_url!)!) { image in image.resizable()}
                        .frame(width: 96, height: 54)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    Text(stage.stage_name!.localized)
                        .modifier(Splatfont2(size: 16))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct StageRecordsView: View {
    @EnvironmentObject var record: StageRecordCore
    
    var body: some View {
        List {
            Section(header: Text("Overview").modifier(Splatfont2(size: 16)).foregroundColor(.yellow)) {
                HStack {
                    Text("Jobs")
                    Spacer()
                    Text("\(record.job_num.value)")
                }
                HStack {
                    Text("Clear Ratio")
                    Spacer()
                    Text(String(record.clear_ratio.value) + "%")
                }
                HStack {
                    Text("Max Grade")
                    Spacer()
                    Text("\(record.grade_point.value)")
                }
            }
            .modifier(Splatfont2(size: 16))
            Section(header: Text("Record").modifier(Splatfont2(size: 16)).foregroundColor(.yellow)) {
                HStack {
                    Text("All")
                    Spacer()
                    Text("\(record.team_golden_eggs[0].value)")
                }
                HStack {
                    Text("No Night Event")
                    Spacer()
                    Text("\(record.team_golden_eggs[1].value)")
                }
            }
            .modifier(Splatfont2(size: 16))
            ForEach(Range(0 ... 2)) { tide in
                Section(header: Text("\((WaveType.init(water_level: tide)?.water_name)!.localized)").modifier(Splatfont2(size: 16)).foregroundColor(.orange)) {
                    ForEach(Range(0 ... 6)) { event in
                        if record.golden_eggs[tide][event] != nil {
                            NavigationLink(destination: ResultView(result: record.salmon_id[tide][event]!)) {
                                HStack {
                                    Text("\((EventType.init(event_id: event)?.event_name)!.localized)")
                                    Spacer()
                                    Text("\(record.golden_eggs[tide][event].value)")
                                }
                            }
                        }
                    }
                }
                .modifier(Splatfont2(size: 16))
            }
        }
        .navigationTitle((StageType.init(stage_id: record.stage_id!)?.stage_name!)!.localized)
    }
}

struct StageRecordView_Previews: PreviewProvider {
    static var previews: some View {
        StageRecordView()
    }
}
