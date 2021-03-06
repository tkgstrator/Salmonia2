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
    @Published var job_num: Int = 0
    @Published var ikura_total: Int = 0
    @Published var defeated: Int = 0
    @Published var golden_ikura_total: Int = 0
    @Published var imageUri: String?
    @Published var srpower: Double?
    @Published var isFav: Bool = false
    @Published var value: Double = 0.0
    
    init(_ pid: String) {
        token = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", pid).observe { [self] _ in
            guard let crew = realm.objects(CrewInfoRealm.self).filter("nsaid=%@", pid).first else { return }
            nsaid = pid
            imageUri = crew.image ?? DEFAULT_IMAGE
            nickname = crew.name.value
            job_num = crew.job_num
            ikura_total = crew.ikura_total
            defeated = crew.boss_defeated
            golden_ikura_total = crew.golden_ikura_total
            srpower = crew.srpower.value
            isFav = crew.isFav
        }
    }
    
    deinit {
        token?.invalidate()
    }
}
