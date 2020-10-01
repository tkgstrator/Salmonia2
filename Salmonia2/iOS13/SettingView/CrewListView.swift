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
//    @State var isVisible: Bool = false
    
    var body: some View {
        List {
            ForEach(user.favuser.indices, id:\.self) { idx in
                HStack {
                    URLImage(URL(string: user.favuser[idx].image)!, content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
                        .frame(width: 60, height: 60)
                    Text(user.favuser[idx].name).frame(maxWidth: .infinity)
                    Text(String(user.favuser[idx].evalValue)).frame(minWidth: 60)
                }
            }
            .onMove(perform: onMove)
            .onDelete(perform: onDelete)
        }
        .navigationBarTitle("Fav Crews")
        .modifier(Splatfont(size: 20))
        .navigationBarItems(leading: SortButton, trailing: EditButton().font(.system(size: 18)))
        .environment(\.editMode, $editMode)
    }
    
    private var SortButton: some View {
        return AnyView(Button(action: { getValue() }) { Image(systemName: "arrow.up.arrow.down") })
    }
    
    private func getValue() {
        guard let realm = try? Realm() else { return }
        guard let account = realm.objects(SalmoniaUserRealm.self).first else { return }
        
        realm.beginWrite()
        for user in user.favuser {
            user.evalValue = (Double(user.boss_defeated) / Double(user.job_num)).round(digit: 2)
        }
        // ディープコピーしないとデータが消えてしまう
        let order = Array(account.favuser.sorted(byKeyPath: "evalValue", ascending: false))
        account.favuser.removeAll()
        account.favuser.append(objectsIn: order)
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
