//
//  WaveType.swift
//  Salmonia2
//
//  Created by devonly on 2020-10-01.
//

import Foundation

@dynamicMemberLookup
public enum EventType: CaseIterable {
    case none, rush, seeking, griller, mothership, fog, cohock
}

public enum EventTypeName: String, CaseIterable {
    case none = "-"
    case rush = "rush"
    case seeking = "goldie-seeking"
    case griller = "the-grilelr"
    case mothership = "the-mothership"
    case fog = "fog"
    case cohock = "cohock-charge"
}

public enum EventTypeID: Int, CaseIterable {
    case none = 0
    case rush = 1
    case seeking = 2
    case griller = 3
    case mothership = 4
    case fog = 5
    case cohock = 6
}

extension EventTypeID {
    var event_id: Int { rawValue }
}

extension EventTypeName {
    var event_name: String { rawValue }
}

public extension EventType {
    init?(event_id: Int) {
        self.init(EventTypeID(rawValue: event_id))
    }
    
    init?(event_name: String) {
        self.init(EventTypeName(rawValue: event_name))
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<EventTypeID, V>) -> V? {
        self[keyPath]
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<EventTypeName, V>) -> V? {
        self[keyPath]
    }
}

private extension EventType {
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

@dynamicMemberLookup
public enum WaveType: CaseIterable {
    case low, normal, high
}

public enum WaveTypeName: String, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
}

public enum WaveTypeID: Int, CaseIterable {
    case low = 0
    case normal = 1
    case high = 2
}

extension WaveTypeID {
    var water_level: Int { rawValue }
}

extension WaveTypeName {
    var water_name: String { rawValue }
}

public extension WaveType {
    init?(water_level: Int) {
        self.init(WaveTypeID(rawValue: water_level))
    }
    
    init?(water_name: String) {
        self.init(WaveTypeName(rawValue: water_name))
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<WaveTypeID, V>) -> V? {
        self[keyPath]
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<WaveTypeName, V>) -> V? {
        self[keyPath]
    }
}

private extension WaveType {
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
