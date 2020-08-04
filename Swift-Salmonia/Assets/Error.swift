//
//  Error.swift
//  Swift-Salmonia
//
//  Created by devonly on 2020-08-04.
//  Copyright © 2020 devonly. All rights reserved.
//

import Foundation

enum APPError: Error {
    case Response(id: Int, message: String)
    case Internal(id: Int, message: String)
    case Database(id: Int, message: String)
}
