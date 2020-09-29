//
//  Enum.swift
//  Salmonia2
//
//  Created by devonly on 2020-09-22.
//

import Foundation

enum APIError: Error {
    case Response(String, String)
}

enum StageType: String, CaseIterable {
    
    case shakeup = "Spawning Grounds"
    case shakeship = "Marooner's Bay"
    case shakehouse = "Lost Outpost"
    case shakelift = "Salmonid Smokeyard"
    case shakeride = "Ruins of Ark Polaris"
    
}
