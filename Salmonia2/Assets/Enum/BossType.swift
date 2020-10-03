import Foundation

@dynamicMemberLookup
public enum BossType: CaseIterable {
    case goldie, steelhead, flyfish, scrapper, steeleel, stinger, maws, griller, drizzler
}

public enum BossTypeName: String, CaseIterable {
    case goldie = "Goldie"
    case steelhead = "Steelhead"
    case flyfish = "Flyfish"
    case scrapper = "Scrapper"
    case steeleel = "Steel Eel"
    case stinger = "Stinger"
    case mawas = "Maws"
    case griller = "Griller"
    case drizzler = "Drizzler"
}

public enum BossTypeURL: String, CaseIterable {
    case goldie = "9b2673de42f00d4fd836bd4684741505.png"
    case steelhead = "337dde2c83705a75263aefdc15740f1c.png"
    case flyfish = "631ea65c8cc2d9fd04f6c7458914d030.png"
    case scrapper = "79d75f769115befab060b27401538402.png"
    case steeleel = "2466752cf11ef6326e2add430101bff6.png"
    case stinger = "862656b37d071e75ad31750c9e18ed15.png"
    case mawas = "367e6e1c33ab3ae2a1c857f4c75f017e.png"
    case griller = "7f8e44737240e3caa52d6c4f457164d9.png"
    case drizzler = "7ecdec1e23a3d0089b38038b0217827c.png"
}

public enum BossTypeID: Int, CaseIterable {
    case goldie = 3
    case steelhead = 6
    case flyfish = 9
    case scrapper = 12
    case steeleel = 13
    case stinger = 14
    case mawas = 15
    case griller = 16
    case drizzler = 21
}

extension BossTypeID {
    var boss_id: Int { rawValue }
}

extension BossTypeURL {
    var image_url: String { rawValue }
}

extension BossTypeName {
    var boss_name: String { rawValue }
}

public extension BossType {
    init?(boss_id: Int) {
        self.init(BossTypeID(rawValue: boss_id))
    }

    init?(boss_name: String) {
        self.init(BossTypeName(rawValue: boss_name))
    }

    init?(image_url: String) {
        self.init(BossTypeURL(rawValue: image_url))
    }

    subscript<V>(dynamicMember keyPath: KeyPath<BossTypeID, V>) -> V? {
        self[keyPath]
    }

    subscript<V>(dynamicMember keyPath: KeyPath<BossTypeURL, V>) -> V? {
        self[keyPath]
    }

    subscript<V>(dynamicMember keyPath: KeyPath<BossTypeName, V>) -> V? {
        self[keyPath]
    }
}

private extension BossType {
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
