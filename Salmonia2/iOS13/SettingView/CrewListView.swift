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
                }
            }
            .onMove(perform: onMove)
            .onDelete(perform: onDelete)
        }
        .navigationBarTitle("Fav Crews")
        .modifier(Splatfont(size: 20))
        .navigationBarItems(trailing: EditButton())
        .environment(\.editMode, $editMode)
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
