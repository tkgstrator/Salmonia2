//
//  CrewListView.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import SwiftUI
import URLImage
import RealmSwift

struct CrewListView: View {
    
    @EnvironmentObject var user: SalmoniaUserCore
    @State private var editMode = EditMode.inactive
    @State var isVisible: Bool = false
    @State var isFinding: Bool = false
    @State var selection: Int = 0
    //    @State var isVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(user.favuser.indices, id:\.self) { idx in
                    NavigationLink(destination: OtherPlayerView().environmentObject(CrewInfoCore(user.favuser[idx].nsaid))) {
                        HStack {
                            URLImage(url: URL(string: user.favuser[idx].image ?? DEFAULT_IMAGE)!) { image in image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0)) }
                                .frame(width: 60, height: 60)
                            Text(user.favuser[idx].name.value).frame(maxWidth: .infinity)
                            Text(user.favuser[idx].evalValue.value.value).frame(minWidth: 60)
                        }
                    }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            AddButton.padding(.trailing, 20).padding(.bottom, 80)
        }
        .environment(\.editMode, $editMode)
        .navigationBarTitle("Fav Crews", displayMode: .large)
        .modifier(Splatfont(size: 20))
    }
    
    private var AddButton: some View {
        NavigationLink(destination: CrewSearchView()){
            ZStack {
                Circle().frame(width: 60, height: 60).foregroundColor(.blue)
                Image(systemName: "plus")
                    .Modifier()
            }
        }.buttonStyle(PlainButtonStyle())
    }
    
//    private var AddButton: some View {
//        HStack {
//            NavigationLink(destination: CrewSearchView().environmentObject(SalmoniaUserCore())) {
//                Text("Add")
//            }
//            EditButton()
//        }.font(.system(size: 18))
//    }
    
    private var SortButton: some View {
        HStack {
            Button(action: { isVisible.toggle() }) { Image(systemName: "arrow.up.arrow.down").padding(.horizontal) }
        }.sheet(isPresented: $isVisible) { CrewFilterView }
    }
    
    private var CrewFilterView: some View {
        List {
            Section(header: HStack {
                Text("Sorting Fav Crew Member")
                    .frame(maxWidth: .infinity)
                    .modifier(Splatfont(size: 22))
            }) {
                Picker("", selection: $selection) {
                    Text("Job Nums").tag(0)
                    Text("SR Power").tag(1)
                    Text("Avg Power Eggs").tag(2)
                    Text("Avg Golden Eggs").tag(3)
                    Text("Avg Defeated").tag(4)
                }
            }
        }.onDisappear() { getValue(isSelect: selection) }
    }
    
    private func getValue(isSelect: Int) {
        realm.beginWrite()
        for crew in user.favuser {
            switch isSelect {
            case 0:
                crew.evalValue.value = Double(crew.job_num)
            case 1:
                crew.evalValue.value = crew.srpower.value
            case 2:
                crew.evalValue.value = (Double(crew.ikura_total) / Double(crew.job_num)).round(digit: 2)
            case 3:
                crew.evalValue.value = (Double(crew.golden_ikura_total) / Double(crew.job_num)).round(digit: 2)
            case 4:
                crew.evalValue.value = (Double(crew.boss_defeated) / Double(crew.job_num)).round(digit: 2)
            default:
                break
            }
        }
        // ディープコピーしないとデータが消えてしまう
        let order = Array(user.favuser.sorted(byKeyPath: "evalValue", ascending: false))
        user.favuser.removeAll()
        user.favuser.append(objectsIn: order)
        try? realm.commitWrite()
    }
    
    private func onDelete(offsets: IndexSet) {
        try? Realm().write {
            user.favuser.remove(atOffsets: offsets)
        }
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        try? Realm().write {
            user.favuser.move(fromOffsets: source, toOffset: destination)
        }
    }
}

struct CrewListView_Previews: PreviewProvider {
    static var previews: some View {
        CrewListView()
    }
}
