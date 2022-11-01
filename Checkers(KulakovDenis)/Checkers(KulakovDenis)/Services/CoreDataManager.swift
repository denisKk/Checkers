//
//  CoreDataManager.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 28.06.22.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HistoryGamesDB")

        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveGameToBase(by game: GameHistory) {

        let gameDB =  GamesDB(context: self.context)
        gameDB.setValues(by: game)

        game.players.forEach {
            let playerDB = PlayersDataDB(context: self.context)
            playerDB.setValues(by: $0)
            gameDB.addToPlayers(playerDB)
        }
        self.context.insert(gameDB)
        saveContext()
    }

    func clearDataBase() {
        deleteAllHistory()
    }

    func getAllGamesDB() -> [GameHistory] {
        let request = GamesDB.fetchRequest()

        let sort = NSSortDescriptor(key: #keyPath(GamesDB.date), ascending: false)
        request.sortDescriptors = [sort]

        guard let gamesDB = try? self.context.fetch(request) else { return [] }
        return gamesDB.map { $0.getMappedGame() }
    }

    private func deleteAllHistory() {
        let result = GamesDB.fetchRequest()
        do {
            let data = try self.context.fetch(result)

            data.forEach {
                self.context.delete($0)
            }

            self.saveContext()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func saveContext() {
        let context = context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
