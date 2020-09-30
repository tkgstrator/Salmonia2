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
    
    @EnvironmentObject var user: CrewInfoCore
    @State private var editMode = EditMode.inactive
//    @State var isVisible: Bool = false
    
    var body: some View {
        List {
            ForEach(user.crews.indices, id:\.self) { idx in
                HStack {
//                    URLImage(URL(string: user.account[idx].image)!, content: { $0.image.resizable().clipShape(RoundedRectangle(cornerRadius: 8.0))})
//                        .frame(width: 60, height: 60)
                    Text(user.crews[idx].nsaid).frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("Fav Crews")
        .modifier(Splatfont(size: 20))
        .navigationBarItems(leading: addButton, trailing: EditButton())
        .environment(\.editMode, $editMode)
    }
    
    private func onDelete(offsets: IndexSet) {
        try? Realm().write {
//            user.account.remove(atOffsets: offsets)
        }
    }
    
    private var addButton: some View {
        switch editMode {
        case .active:
            return AnyView(Button(action: { }) { Image(systemName: "plus") })
        default:
            return AnyView(EmptyView().frame(width: 0))
        }
    }
}

struct CrewListView_Previews: PreviewProvider {
    static var previews: some View {
        CrewListView()
    }
}
