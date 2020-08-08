//
//  StageRecordsView.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-03.
//  Copyright © 2020 devonly. All rights reserved.
//

import SwiftUI
import RealmSwift
import URLImage

struct StageListView: View {
//    @ObservedObject var records = UserResultsCore()
    @State var stage_list: [Int] = [5000, 5001, 5002, 5003, 5004]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Stage Records")
                .frame(height: 28)
                .foregroundColor(.orange)
                .font(.custom("Splatoon1", size: 20))
            ForEach(stage_list.indices, id:\.self) { idx in
                HStack {
                    NavigationLink(destination: StageRecordsView(id: self.$stage_list[idx])) {
                        URLImage(URL(string: ImageURL.stage(self.stage_list[idx]))!, content: {$0.image.resizable()})
                            .frame(width: 112, height: 63)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    Spacer()
                    Text(ImageURL.stagename(self.stage_list[idx])).frame(maxWidth: .infinity)
                }.font(.custom("Splatoon1", size: 20))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

private struct StageRecordsView: View {
    @ObservedObject var stage = UserResultsCore()
    @Binding var stage_id: Int

    init(id: Binding<Int>) {
        _stage_id = id
        stage.filter(stage_id)
    }
    
    var body: some View {
        ScrollView {
            // 概要表示
            ZStack {
                URLImage(URL(string: ImageURL.stage(stage_id))!, content: { $0.image.resizable().aspectRatio(contentMode: .fill).opacity(0.5) }).frame(maxWidth: .infinity)
                HStack(alignment: .top) {
                    VStack {
                        Text("Jobs")
                        Text("\(stage.job_num.value)")
                    }
                    VStack {
                        Text("Avg")
                        VStack(spacing: 0) {
                            HStack {
                                Text(String(stage.team_avg_golden_eggs.value)).foregroundColor(.yellow)
                                Text("/")
                                Text(String(stage.team_avg_power_eggs.value)).foregroundColor(.red)
                            }
                            HStack {
                                Text(String(stage.my_avg_golden_eggs.value)).foregroundColor(.yellow)
                                Text("/")
                                Text(String(stage.my_avg_power_eggs.value)).foregroundColor(.red)
                            }
                            .font(.custom("Splatoon1", size: 18))
                            .frame(height: 18)
                        }
                    }
                    VStack {
                        Text("Win")
//                        Text(String(win_ratio))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 5)
            }
            // まだ工事中のところ
            ZStack {
                // 背景のシャケ
                URLImage(URL(string: "https://www.nintendo.co.jp/switch/aab6a/assets/images/salmonrun_pic.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fill).opacity(0.5) }).frame(maxWidth: .infinity)
//                ResultsCollectionView()
                // 実際のジャンプボタン
                VStack {
                    Text("Max")
                    VStack(spacing: 0) {
                        HStack {
                            Text(String(stage.team_max_golden_eggs.value)).foregroundColor(.yellow)
                            Text("/")
                            Text(String(stage.team_max_power_eggs.value)).foregroundColor(.red)
                        }
                        HStack {
                            Text(String(stage.my_max_golden_eggs.value)).foregroundColor(.yellow)
                            Text("/")
                            Text(String(stage.my_max_power_eggs.value)).foregroundColor(.red)
                        }
                        .font(.custom("Splatoon1", size: 18))
                        .frame(height: 18)
                    }
                    NavigationLink(destination: GoldenEggRecordsView()) {
                        URLImage(URL(string: "https://app.splatoon2.nintendo.net/images/bundled/3aa6fb4ec1534196ede450667c1183dc.png")!, content: { $0.image.resizable().aspectRatio(contentMode: .fill) }).frame(width: 72, height: 72)
                    }.buttonStyle(PlainButtonStyle())
                }
                // 実際のジャンプボタン
            }
        }
        .font(.custom("Splatoon1", size: 22))
        .navigationBarTitle(ImageURL.stagename(stage_id))
    }
}

//struct StageRecordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        StageRecordsView()
//    }
//}

struct StageRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
struct StageListView_Previews: PreviewProvider {
    static var previews: some View {
        StageListView()
    }
}
