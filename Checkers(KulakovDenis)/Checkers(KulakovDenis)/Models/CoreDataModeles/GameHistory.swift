//
//  GameHistory.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 28.06.22.
//

import Foundation

class GameHistory {
    var date: Date
    var timeLimit: TimeType
    var boardSize: BoardSize
    var players: [PlayerHistory]

    init(date: Date, timeLimit: TimeType, boardSize: BoardSize, players: [PlayerHistory]) {
        self.date = date
        self.timeLimit = timeLimit
        self.boardSize = boardSize
        self.players = players
    }
}
