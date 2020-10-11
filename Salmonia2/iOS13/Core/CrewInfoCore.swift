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

let realm = try! Realm()

class CrewInfoCore: ObservableObject {
    private var token: NotificationToken?

    @Published var nsaid: String = ""
    @Published var nickname: String = ""
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    @Published var imageUri: String = ""
    @Published var srpower: Double?
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
        token = realm.objects(CrewInfoRealm.self).observe { [self] _ in
            guard let crew = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = realm.objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            imageUri = crew.image
            nickname = crew.name
            job_num = crew.job_num
            ikura_total = crew.ikura_total
            golden_ikura_total = crew.golden_ikura_total
            srpower = crew.srpower.value
            isFav = !favuser.isEmpty
        }
        
        token = realm.objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let crew = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = realm.objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            imageUri = crew.image
            nickname = crew.name
            job_num = crew.job_num
            ikura_total = crew.ikura_total
            golden_ikura_total = crew.golden_ikura_total
            srpower = crew.srpower.value
            isFav = !favuser.isEmpty
        }
    }
}
