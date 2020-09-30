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
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    @Published var isFav: Bool = false

    init(_ pid: String) {
        token = try? Realm().objects(CrewInfoRealm.self).observe { [self] _ in
            guard let crew = try? Realm().objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = try? Realm().objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            job_num = crew.job_num
            ikura_total = crew.ikura_total
            golden_ikura_total = crew.golden_ikura_total
            
            isFav = !favuser.isEmpty
            print("ISFAV", !favuser.isEmpty)
        }
        
        token = try? Realm().objects(SalmoniaUserRealm.self).observe { [self] _ in
            guard let crew = try? Realm().objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            guard let favuser = try? Realm().objects(SalmoniaUserRealm.self).first?.favuser.filter("nsaid=%@", pid) else { return }
            nsaid = pid
            job_num = crew.job_num
            ikura_total = crew.ikura_total
            golden_ikura_total = crew.golden_ikura_total
            isFav = !favuser.isEmpty
            print("ID", pid, nsaid, "ISFAV", !favuser.isEmpty)
        }
    }
}
