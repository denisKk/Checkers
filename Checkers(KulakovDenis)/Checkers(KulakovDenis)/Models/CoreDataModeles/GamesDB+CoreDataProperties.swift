//
//  GamesDB+CoreDataProperties.swift
//  
//
//  Created by Dev on 28.06.22.
//
//

import Foundation
import CoreData

extension GamesDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GamesDB> {
        return NSFetchRequest<GamesDB>(entityName: "GamesDB")
    }

    @NSManaged public var date: Date
    @NSManaged public var timeLimit: Int16
    @NSManaged public var boardSize: Int16
    @NSManaged public var players: NSSet?

    func setValues(by game: GameHistory) {
        self.date = game.date
        self.timeLimit = Int16(game.timeLimit.rawValue)
        self.boardSize = Int16(game.boardSize.rawValue)
    }

    func getMappedGame() -> GameHistory {
        return GameHistory(
            date: date,
            timeLimit: TimeType(rawValue: Int(timeLimit)) ?? .unlimit,
            boardSize: BoardSize(rawValue: Int(boardSize)) ?? .size8x8,
            players: players?
                .compactMap {$0 as? PlayersDataDB}
                .compactMap {$0.getMappedPlayer()} ?? [])
    }
}

    // MARK: Generated accessors for players
    extension GamesDB {

        @objc(addPlayersObject:)
        @NSManaged public func addToPlayers(_ value: PlayersDataDB)

        @objc(removePlayersObject:)
        @NSManaged public func removeFromPlayers(_ value: PlayersDataDB)

        @objc(addPlayers:)
        @NSManaged public func addToPlayers(_ values: NSSet)

        @objc(removePlayers:)
        @NSManaged public func removeFromPlayers(_ values: NSSet)

    }
