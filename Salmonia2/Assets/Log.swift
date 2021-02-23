//
//  Log.swift
//  Salmonia2
//
//  Created by devonly on 2020-11-20.
//

import Foundation
import SwiftUI

struct ProgressLog {
    var progress: CGFloat = 0.0 // 進行度を表す値
    var localizedDescription: String? // 現在の状態を出力
    var errorCode: Int? // エラーコード
    var errorDescription: String? // エラーの内容
}
