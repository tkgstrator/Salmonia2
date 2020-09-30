//
//  Enum.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation
import SwiftUI

enum APIError: Error {
    case Response(String, String)
}

struct UserId: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var nsaid: String? {
        get {
            return self[UserId]
        }
        set {
            self[UserId] = newValue
        }
    }
}
//enum StageTypeID: CaseIterable {
//    case shakeup, shakeship, shakehouse, shakelift, shakeride
//
//    var stage_id: Int {
//        switch self {
//        case .shakeup:
//            return 5000
//        case .shakeship:
//            return 5001
//        case .shakehouse:
//            return 5002
//        case .shakelift:
//            return 5003
//        case .shakeride:
//            return 5004
//        }
//    }
//
//    var stage_name: String {
//        switch self {
//        case .shakeup:
//            return "Spawning Grounds"
//        case .shakeship:
//            return "Marooner's Bay"
//        case .shakehouse:
//            return "Lost Outpost"
//        case .shakelift:
//            return "Salmonid Smokeyard"
//        case .shakeride:
//            return "Ruins of Ark Polaris"
//        }
//    }
//
//    var image_url: URL {
//        switch self {
//        case .shakeup:
//            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_stage/65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png")!
//        case .shakeship:
//            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_stage/e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png")!
//        case .shakehouse:
//            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_stage/6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png")!
//        case .shakelift:
//            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_stage/e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png")!
//        case .shakeride:
//            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_stage/50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png")!
//        }
//    }
//}
