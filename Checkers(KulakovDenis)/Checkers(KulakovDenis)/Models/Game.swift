//
//  Game.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 26.05.22.
//

import Foundation
import UIKit


enum TimeType: Int, CaseIterable {
    
    case unlimit = 0
    case tier1 = 1
    case tier2 = 5 // 5 * 60
    case tier3 = 10 // 10 * 60
    case tier4 = 15 // 15 * 60
    
    func description() -> String {
        switch self {
            
        case .unlimit:
            return "∞"
        default:
            return "\(self.rawValue) " + "min".localized
        }
    }
}


enum GameState {
    case none
    case load
    case start
    case play
    case wait
    case finish
}

enum MessageType {
    case winner
    case draw
}

class Game {
    static let shared = Game()
    
    private(set) var durationTime: Int = 0
    private(set) var chessArray: [Int] = []
    private var fireStepArray: [[FireStep]] = []
    
    var gameTimer = Timer()
    var playerChanged: (() -> ())?
    var showStep: ((_ fromTag: Int, _ toTag: Int) -> ())?
    var showMessage: ((MessageType, String?) -> ())?
    var timeLimit: TimeType = .unlimit
    var gameChessColors: [ChessColor] = [.white, .black]
    
    private(set) var state: GameState = .none {
        didSet {
            changeGameState()
        }
    }
    
    func changeGameState(){
        switch state {
        case .none:
            print("none state")
        case .start:
            print("start state")
            startGame()
        case .play:
            print("play state")
            startTimer()
        case .wait:
            print("wait state")
        case .finish:
            finishGame()
        case .load:
            
            loadLocalData()
            
        }
    }
    
    var players: [Player] = []
    
    func startTimer() {
        
        guard !gameTimer.isValid else {return}
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if let player = currentStep {
                switch timeLimit {
                case .unlimit:
                    player.time += 1
                default:
                    player.time -= 1
                    if player.time <= 0 {
                      //  state = .finish
                        player.result = .lose
                    }
                }
            }
        })
    }
    
    
    func loadGame() {
        addPlayers()
        state = .load
    }
    
    func rematchGame(){
        gameChessColors.swapAt(0, 1)
        Settings.shared.rematchData()
        loadGame()
    }
    
    func startGame() {
        state = .play
        nextPlayer()
    }
    
    func finishGame(){
        gameTimer.invalidate()
        saveGameToBase()
    }
    
    func abortGame(){
        
    }
    
    func saveGameToBase(){
        
        let players = players.map { player in
            PlayerHistory(name: player.name, result: player.result, time: player.time, color: player.color)
        }
        let gameHistory = GameHistory(date: Date(), timeLimit: timeLimit, boardSize: Settings.shared.boardSize, players: players)
        CoreDataManager.shared.saveGameToBase(by: gameHistory)
    }
    
    func addPlayers(){
        players.removeAll()
        
        for color in gameChessColors {
            let player = Player(name: "Player \(color.rawValue)", color: color, time: timeLimit.rawValue)
            player.didResultChanged = { [weak self] in
                switch player.result {
                case .win:
                    self?.finishGame()
                    self?.showMessage?(.winner, player.name)
                case .lose, .abort:
                    if let otherPlayer = self?.players.first(where: {$0.name != player.name }) {
                        otherPlayer.result = .win
                    }
                case .draw:
                    if let _ = self?.players.first(where: {$0.result != .draw }) {
                        self?.showMessage?(.draw, player.name)
                    } else {
                        self?.finishGame()
                        self?.showMessage?(.winner, nil)
                    }
                default: break
                }
            }
            players.append(player)
        }
    }
    
    func getPlayerBy(color: ChessColor) -> Player? {
        if let player = players.first(where: {$0.color == color}) {
            return player
        }
        return nil
    }
    
    func changeGameState(to state: GameState) {
        self.state = state
    }

    
    func loadLocalData() {

        chessArray = Settings.shared.chessArray ?? arrayForStartPosition()
        timeLimit = Settings.shared.timeLimit
        
        if let player = getPlayerBy(color: .black), let savedName = Settings.shared.secondPlayerName {
            player.name = savedName
            player.time = Settings.shared.topPlayerTime == 0 ? timeLimit.rawValue * 60 : Settings.shared.topPlayerTime
        }
        
        if let player = getPlayerBy(color: .white) {
            player.name = Settings.shared.userName ?? ""
            player.time = Settings.shared.bottomPlayerTime == 0 ? timeLimit.rawValue * 60 : Settings.shared.bottomPlayerTime
        }
        
        if players.first?.color != Settings.shared.currentStep {
            players.swapAt(0, 1)
        }
    }
    
    func nextPlayer() {
        guard let currentStep = players.first else {return}
        self.currentStep = currentStep
        players.swapAt(0, 1)
        playerChanged?()
    }
    
    
    func isFinishGame() -> Bool{
        guard let _ = getTagsForBorders() else {return true}
        return false
    }
    
    var currentStep: Player? {
        didSet{

            oldValue?.isActive = false
            
            guard !isFinishGame() else {
                currentStep?.result = .lose
                return
            }
            
            currentStep?.isActive = true
        }
    }
    
    func arrayForStartPosition() -> [Int] {
        var array = Array(repeating: 0, count: Int(BOARD_SIZE*BOARD_SIZE / 2))
        for i in 0..<(BOARD_SIZE/2-1)*BOARD_SIZE/2 {
            array[i] = ChessType.white.rawValue
            array[array.count - (i + 1)] = ChessType.black.rawValue
        }
        return array
    }
    
    func saveGame(){
        Settings.shared.chessArray = chessArray
        Settings.shared.currentStep = currentStep?.color ?? .white
        Settings.shared.bottomPlayerTime = getPlayerBy(color: .white)?.time ?? 0
        Settings.shared.topPlayerTime = getPlayerBy(color: .black)?.time ?? 0
        // Settings.shared.gameTimeInSeconds = gameTimeInSeconds
    }
    
    
    func getChessType(by tag: Int) -> ChessType? {
        if let index = getIndexByTag(tag){
            let value = chessArray[index]
            return ChessType(rawValue: value)
        }
        return nil
    }
    
    
    func getTagsForBorders() -> [Int]? {
        tagsForMustFire() ?? tagsForCanStep() ?? nil
    }
    
    func tagsForMustFire() -> [Int]? {
        var arrayIndexes: [Int] = []
        for (index, value) in chessArray.enumerated() {
            if let chessType = ChessType(rawValue: value),
               chessType != .none, chessType.getChessColor() == currentStep?.color
            {
                for direction in Direction.allDirections {
                    if checkFireBy(tag: getTagByIndex(index), in: direction, for: chessType) {
                        arrayIndexes.append(getTagByIndex(index))
                    }
                }
            }
        }
        return arrayIndexes.isEmpty ? nil : arrayIndexes
    }
    
    func tagsForCanStep() -> [Int]? {
        var arrayIndexes: [Int] = []
        for (index, value) in chessArray.enumerated() {
            if let chessType = ChessType(rawValue: value),
               chessType != .none, chessType.getChessColor() == currentStep?.color
            {
                for direction in chessType.getDirections() {
                    if checkStepBy(tag: getTagByIndex(index), direction: direction) {
                        arrayIndexes.append(getTagByIndex(index))
                        break
                    }
                }
            }
        }
        return arrayIndexes.isEmpty ? nil : arrayIndexes
    }
    
    
    func checkFireBy(tag: Int, in direction: Direction, for chessType: ChessType) -> Bool {
        
        guard chessType.isQueen() else
        {
            if let firstType = getChessType(by: tag + direction.rawValue),
               firstType.isOpponent(for: chessType),
               getChessType(by: tag + 2 * direction.rawValue) == ChessType.none
            {
                return true
            }
            
            return false
        }
        
        var newTag = tag + direction.rawValue
        while getChessType(by: newTag) == ChessType.none {
            newTag += direction.rawValue
        }
        
        if let firstType = getChessType(by: newTag),
           firstType.isOpponent(for: chessType),
           getChessType(by: newTag + direction.rawValue) == ChessType.none
        {
            return true
        }
        return false
    }
    
//    func getTagsByCurrrentColor() -> [Int] {
//        getTags(by: currentStep!.color)
//    }
    
    func getFreeCells(startTag: Int, direction: Direction) -> [Int] {
        var array = [Int]()
        var newTag = startTag
        while checkStepBy(tag: newTag, direction: direction) {
            newTag += direction.rawValue
            array.append(newTag)
        }
        return array
    }
    
    func getFireCells(startTag: Int, direction: Direction, type: ChessType) -> [Int]? {
        var array = [Int]()
        var newTag = startTag
        while let index = getIndexByTag(newTag), chessArray[index] == ChessType.none.rawValue {
            
            for checkDirection in direction.otherDirections() {
                if checkFireBy(tag: newTag, in: checkDirection, for: type) {
                    array.append(newTag)
                }
            }
            newTag += direction.rawValue
        }
        return array.isEmpty ? nil : array
    }
    
    
    func getTagsToCanStep(tag: Int) -> [Int]? {
        guard let chessType = getChessType(by: tag) else {return nil}
        
        fireStepArray.removeAll()
        getFireSteps(for: tag, directions: Direction.allDirections, type: chessType)
        
        if fireStepArray.isEmpty, tagsForMustFire() == nil {
            var array: [Int] = []
            
            let directions =  chessType.getDirections()
            for direction in directions {
                if checkStepBy(tag: tag, direction: direction)
                {
                    if chessType.isQueen() {
                        var newTag = tag + direction.rawValue
                        while checkStepBy(tag: newTag, direction: direction) {
                            newTag += direction.rawValue
                            array.append(newTag)
                        }
                    }
                    array.append(tag + direction.rawValue)
                }
            }
            return array.isEmpty ? nil : array
            
        } else {
            var array: [Int] = []
            for subArray in fireStepArray {
                array.append(contentsOf: subArray.map({$0.toTag}))
            }
            return array.isEmpty ? nil : array
        }
    }
    
    func getTags(by color: ChessColor) -> [Int] {
        var array: [Int] = []
        for (index, value) in chessArray.enumerated() {
            if let chessColor = ChessType(rawValue: value)?.getChessColor(), color == chessColor {
                array.append(getTagByIndex(index))
            }
        }
        return array
    }
    
    func checkStepBy(tag: Int, direction: Direction) -> Bool {
        return getChessType(by: tag + direction.rawValue) == ChessType.none ? true : false
    }
    
    func getFireSteps(for tag: Int, directions: [Direction], type: ChessType, array: [FireStep] = []) {
        var newArray: [FireStep] = []
        var countDirection = 0
        for direction in directions {
            newArray = array
            var nextTag = tag
            if type.isQueen() {//}, array.isEmpty {
                while getChessType(by: nextTag + direction.rawValue) == ChessType.none {
                    nextTag += direction.rawValue
                }
            }
            
            if checkFireBy(tag: nextTag, in: direction, for: type) {
                
                let newTag = nextTag + 2 * direction.rawValue
                let newDirections = direction.otherDirections()
                
                
                
                if type.isQueen() {
                    if let array = getFireCells(startTag: newTag, direction: direction, type: type) {
                        for elementTag in array {
                            let filter = newArray.map({getFireTag(by: $0)})
                            let fireStep = FireStep(fromTag: tag, toTag: elementTag)
                            if !filter.contains(getFireTag(by: fireStep)) {
                                getFireSteps(for: elementTag, directions: newDirections, type: type, array: newArray + [fireStep])
                                countDirection += 1
                            }
                        }
                        newArray.removeAll()
                    } else {
                        let array = getFreeCells(startTag: newTag, direction: direction)
                        
                        let filter = newArray.map({getFireTag(by: $0)})
                        let fireStep = FireStep(fromTag: tag, toTag: newTag)
                        if !filter.contains(getFireTag(by: fireStep)) {
                            fireStepArray.append(newArray + [fireStep])
                            countDirection += 1
                            for elementTag in array {
                                fireStepArray.append(newArray + [FireStep(fromTag: tag, toTag: elementTag)])
                            }
                        }
                        
                        newArray.removeAll()
                    }
                    
                }
                else {
                    newArray.append(FireStep(fromTag: tag, toTag: newTag))
                    var newType = type
                    if type == .white && newTag > (BOARD_SIZE * (BOARD_SIZE - 1)) {
                        newType = ChessType.whiteQueen
                    }
                    
                    if type == .black && newTag <= BOARD_SIZE {
                        newType = ChessType.blackQueen
                    }
                    
                    getFireSteps(for: newTag, directions: newDirections, type: newType, array: newArray )
                    countDirection += 1
                }
            }
        }
        if !newArray.isEmpty, countDirection == 0 {
            fireStepArray.append(newArray)
        }
    }
    
    
    var continueArray = [FireStep]()
    
    func isQueenZoneBy(index: Int, forColor: ChessColor) -> Bool {
        if (index < BOARD_SIZE/2 && forColor == .black) || (index >= ((BOARD_SIZE * BOARD_SIZE)/2 - BOARD_SIZE/2) && forColor == .white) {
            return true
        }
        return false
    }
    
    func startStep(fromTag: Int, toTag: Int) {
        continueArray.removeAll()
        guard let fromIndex = getIndexByTag(fromTag),
              let toIndex = getIndexByTag(toTag),
              let chessColor = getChessType(by: fromTag)?.getChessColor()
        else {return}
        showStep?(fromTag, toTag)
        chessArray.swapAt(fromIndex, toIndex)
        
        
        if let chessType = getChessType(by: toTag),
           chessType.isQueen() == false,
           isQueenZoneBy(index: toIndex, forColor: chessColor)
        {
            continueArray.append(FireStep(fromTag: toTag, toTag: toTag))
        }
        
        
        let filter = fireStepArray.filter{item in
            item.contains {$0.toTag == toTag}
        }
        if let steparray = filter.max(by: {$0.count < $1.count}) {
            
            if let stepIndex = steparray.firstIndex(where: {$0.toTag == toTag}){
                
                for i in 0..<steparray.count {
                    let step = steparray[i]
                    if i <= stepIndex {
                        if let toIndex = getIndexByTag(step.toTag) {
                            
                            if isQueenZoneBy(index: toIndex, forColor: chessColor), getChessType(by: step.toTag)?.isQueen() == false {
                                continueArray.append(FireStep(fromTag: toTag, toTag: toTag))
                            }
                        }
                    } else {
                        continueArray.append(FireStep(fromTag: step.fromTag, toTag: step.toTag))
                        if let toIndex = getIndexByTag(step.toTag) {
                            if isQueenZoneBy(index: toIndex, forColor: chessColor), getChessType(by: step.toTag)?.isQueen() == false {
                                continueArray.append(FireStep(fromTag: step.toTag, toTag: step.toTag))
                            }
                        }
                    }
                    let fireTag = getFireTag(by: step)
                    
                    continueArray.append(FireStep(fromTag: -1 * fireTag, toTag: -1 * fireTag))
                }
            }
        }
    }
    
    func nextStep(){
        if continueArray.isEmpty {
            nextPlayer()
        }
        else {
            
            let nextStep = continueArray.removeFirst()
            guard let toIndex = getIndexByTag(abs(nextStep.toTag)),
                  let fromIndex = getIndexByTag(abs(nextStep.fromTag))
            else {return}
            
            if nextStep.toTag == nextStep.fromTag {
                if nextStep.toTag > 0 {
                    if let chessType = getChessType(by: nextStep.toTag){
                        chessArray[toIndex] = chessType.upgrade().rawValue
                    }
                    
                } else {
                    self.chessArray[toIndex] = ChessType.none.rawValue
                }
                
                showStep?(nextStep.toTag, nextStep.toTag)
            }
            else {
                chessArray.swapAt(fromIndex, toIndex)
                showStep?(nextStep.fromTag, nextStep.toTag)
            }
        }
    }
    
    
    func getFireTag(by step: FireStep) -> Int {
        let direction = getDirection(by: step).rawValue
        var newTag = step.toTag + direction
        while let index = getIndexByTag(newTag), chessArray[index] == ChessType.none.rawValue {
            newTag += direction
        }
        return newTag
    }
    
    func getDirection(by fireStep: FireStep) -> Direction {
        let delta = fireStep.fromTag - fireStep.toTag
        if delta > 0 {
            if delta % (BOARD_SIZE - 1) == 0 {
                return .topLeft
            }
            else {
                return .topRight
            }
        }
        else {
            if delta % (BOARD_SIZE + 1) == 0 {
                return .bottomLeft
            }
            else {
                return .bottomRight
            }
        }
    }
}


