//
//  PlayerHistory.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 28.06.22.
//

import Foundation

struct PlayerHistory {
    var name: String
    var result: PlayerResult
    var time: Int
    var color: ChessColor

    init(name: String, result: PlayerResult, time: Int, color: ChessColor) {
        self.name = name
        self.result = result
        self.time = time
        self.color = color
    }
}
