//
//  UserCardCore.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class CrewInfoCore: ObservableObject {
    private var token: NotificationToken?
    
    @Published var nsaid: String = ""
    @Published var nickname: String = ""
    @Published var imageUri: String = ""
    @Published var isFav: Bool = false
    @Published var value: Double = 0.0

    enum SortType {
        case golden, power, defeat, help, dead
    }

    
    func getValue(_ type: SortType ) {
        switch type {
        case .golden:
            break
        case .power:
            break
        case .defeat:
            break
        case .help:
            break
        case .dead:
            break
        }
    }
    
    init(_ pid: String) {
        token = try? Realm().objects(CrewInfoRealm.self).observe { [self] _ in
            guard let crew = try? Realm().objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = try? Realm().objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            isFav = !favuser.isEmpty
        }
        
        token = try? Realm().objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let crew = try? Realm().objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = try? Realm().objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            isFav = !favuser.isEmpty
        }
    }
}
