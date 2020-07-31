//
//  Enum.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-07-28.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation

struct Enum {
    public let Stage: [(url: String, name: String)] = [
        ("65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png", "Spawning Grounds"),
        ("e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png", "Marooner's Bay"),
        ("6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png", "Lost Outpost"),
        ("e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png", "Salmonid Smokeyard"),
        ("50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png", "Ruins of Ark Polaris"),
    ]
    
    public let Event: [String] = [
        "-",
        "rush",
        "goldie-seeking",
        "griller",
        "the-mothership",
        "fog",
        "cohock-charge",
    ]
    
    public let Tide: [String] = [
        "low",
        "normal",
        "high"
    ]
    
    public let Records: [Int: [Int: [Int?]]] = [
        0: [ // シェケナダムの情報
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ],
        1: [ // ドンブラコの情報
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ],
        2: [ // シャケト場の記録
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ],
        3: [ // トキシラズの記録
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ],
        4: [ // ポラリスの情報
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ],
        5: [ // 全ステージの記録
            0: [nil, nil, nil],
            1: [nil, nil, nil],
            2: [nil, nil, nil],
            3: [nil, nil, nil],
            4: [nil, nil, nil],
            5: [nil, nil, nil],
            6: [nil, nil, nil]
        ]
    ]
}
