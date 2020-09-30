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
    
    @Published var user: CrewInfoRealm = CrewInfoRealm()
    @Published var crews = try! Realm().objects(CrewInfoRealm.self)
    @Published var nsaid: String = ""
    @Published var nickname: String = ""
    @Published var imageUri: String = ""
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var golden_ikura_total: Int = 0
    @Published var isFav: Bool = false
    
    //
    init() {
        token = try? Realm().objects(CrewInfoRealm.self).observe { [self] _ in
            guard let _crews = try? Realm().objects(CrewInfoRealm.self) else { return }
            crews = _crews.filter("isFav=%@", true)
            print(crews.count)
        }
    }
    
    init(_ pid: String) {
        token = try? Realm().objects(CrewInfoRealm.self).observe { [self] _ in
            guard let _crews = try? Realm().objects(CrewInfoRealm.self) else { return }
            guard let _crew = _crews.filter("nsaid=%@", pid).first else { return }
            crews = _crews.filter("isFav=%@", true)
            user = _crew
            nsaid = pid
            job_num = _crew.job_num
            ikura_total = _crew.ikura_total
            golden_ikura_total = _crew.golden_ikura_total
            isFav = _crew.isFav
            //            guard let nsaid = users.first?.nsaid else { return }
            ////            guard let nsaid = users.filter("isActive=%@", true).first?.nsaid else { return }
            //            guard let realm = try? Realm().objects(CoopCardRealm.self).filter("nsaid=%@", nsaid).first else { return }
            //            job_num = realm.job_num.value ?? 0
            //            ikura_total = realm.ikura_total.value ?? 0
            //            golden_ikura_total = realm.golden_ikura_total.value ?? 0
            ////            kuma_point = realm.kuma_point.value ?? 0
            ////            kuma_point_total = realm.kuma_point_total.value ?? 0
            //            help_total = realm.help_total.value ?? 0
        }
    }
    //
    //        token = try? Realm().objects(UserInfoRealm.self).observe { [self] _ in
    //            guard let users = try? Realm().objects(UserInfoRealm.self) else { return }
    //            guard let nsaid = users.first?.nsaid else { return }
    ////            guard let nsaid = users.filter("isActive=%@", true).first?.nsaid else { return }
    //            guard let realm = try? Realm().objects(CoopCardRealm.self).filter("nsaid=%@", nsaid).first else { return }
    //            job_num = realm.job_num.value ?? 0
    //            ikura_total = realm.ikura_total.value ?? 0
    //            golden_ikura_total = realm.golden_ikura_total.value ?? 0
    ////            kuma_point = realm.kuma_point.value ?? 0
    ////            kuma_point_total = realm.kuma_point_total.value ?? 0
    //            help_total = realm.help_total.value ?? 0
    //        }
    //
    //    }
}
