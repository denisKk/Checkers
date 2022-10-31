//
//  PlayersDataDB+CoreDataProperties.swift
//  
//
//  Created by Dev on 28.06.22.
//
//

import Foundation
import CoreData

extension PlayersDataDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayersDataDB> {
        return NSFetchRequest<PlayersDataDB>(entityName: "PlayersDataDB")
    }

    @NSManaged public var name: String
    @NSManaged public var time: Int16
    @NSManaged public var result: Int16
    @NSManaged public var color: String
    @NSManaged public var game: GamesDB?

    func setValues(by player: PlayerHistory) {
        self.name = player.name
        self.time = Int16(player.time)
        self.color = player.color.rawValue
        self.result = Int16(player.result.rawValue)
    }

    func getMappedPlayer() -> PlayerHistory {
        return PlayerHistory(
            name: name,
            result: PlayerResult(rawValue: Int(result)) ?? .none,
            time: Int(time),
            color: ChessColor(rawValue: color) ?? .black
        )
    }
}
