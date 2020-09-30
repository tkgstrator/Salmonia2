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
        VStack(spacing: 10) {
            Text("Stage Records")
                .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatfont", size: 20))
            ForEach(StageType.allCases, id:\.self) { stage in
                HStack {
//                    NavigationLink(destination: StageRecordsView(record: self.stages.records[idx])) {
                    URLImage(URL(string: stage.image_url!)!, content: {$0.image.resizable()})
                            .frame(width: 112, height: 63)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
//                    }
                    Spacer()
                    Text(stage.stage_name!).frame(maxWidth: .infinity)
                }.font(.custom("Splatfont", size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct StageRecordView_Previews: PreviewProvider {
    static var previews: some View {
        StageRecordView()
    }
}
