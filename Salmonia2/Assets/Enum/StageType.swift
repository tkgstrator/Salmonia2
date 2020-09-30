//
//  StageType.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-29.
//

import Foundation

@dynamicMemberLookup
public enum StageType: CaseIterable {
    case shakeup, shakeship, shakehouse, shakelift, shakeride
}

public enum StageTypeName: String, CaseIterable {
    case shakeup = "Spawning Grounds"
    case shakeship = "Marooner's Bay"
    case shakehouse = "Lost Outpost"
    case shakelift = "Salmonid Smokeyard"
    case shakeride = "Ruins of Ark Polaris"
    
}

public enum StageTypeURL: String, CaseIterable {
    case shakeup    = "https://app.splatoon2.nintendo.net/images/coop_stage/65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png"
    case shakeship  = "https://app.splatoon2.nintendo.net/images/coop_stage/e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png"
    case shakehouse = "https://app.splatoon2.nintendo.net/images/coop_stage/6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png"
    case shakelift  = "https://app.splatoon2.nintendo.net/images/coop_stage/e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png"
    case shakeride  = "https://app.splatoon2.nintendo.net/images/coop_stage/50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png"
}

public enum StageTypeID: Int, CaseIterable {
    case shakeup = 5000
    case shakeship = 5001
    case shakehouse = 5002
    case shakelift = 5003
    case shakeride = 5004
}

extension CaseIterable where Self: Equatable {
    var offset: AllCases.Index {
        Self.allCases.firstIndex(of: self)!
    }
}

extension StageTypeID {
    var stage_id: Int { rawValue }
}

extension StageTypeURL {
    var image_url: String { rawValue }
}

extension StageTypeName {
    var stage_name: String { rawValue }
}

public extension StageType {
    init?(stage_id: Int) {
        self.init(StageTypeID(rawValue: stage_id))
    }

    init?(stage_name: String) {
        self.init(StageTypeName(rawValue: stage_name))
    }

    init?(image_url: String) {
        self.init(StageTypeURL(rawValue: image_url))
    }

    subscript<V>(dynamicMember keyPath: KeyPath<StageTypeID, V>) -> V? {
        self[keyPath]
    }

    subscript<V>(dynamicMember keyPath: KeyPath<StageTypeURL, V>) -> V? {
        self[keyPath]
    }

    subscript<V>(dynamicMember keyPath: KeyPath<StageTypeName, V>) -> V? {
        self[keyPath]
    }
}

private extension StageType {
    init?<T>(_ object: T?) where T: CaseIterable, T.AllCases.Index == AllCases.Index, T: Equatable {
        switch object {
        case let object? where object.offset < Self.allCases.endIndex:
            self = Self.allCases[object.offset]
        case _:
            return nil
        }
    }

    subscript<T, V>(_ keyPath: KeyPath<T, V>) -> V? where T: CaseIterable, T.AllCases.Index == AllCases.Index {
        (offset < T.allCases.endIndex) ? T.allCases[offset][keyPath: keyPath] : nil
    }
}
