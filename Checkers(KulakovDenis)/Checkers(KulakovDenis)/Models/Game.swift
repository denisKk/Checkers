//
//  Game.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 26.05.22.
//

import Foundation
import UIKit


enum GameState {
    case none
    case load
    case start
    case play
    case wait
    case finish
}

class Game {
    static let shared = Game()
    
    private(set) var durationTime: Int = 0
    private(set) var chessArray: [Int] = []
    private var fireStepArray: [[FireStep]] = []
    
    
    var playerChanged: (() -> ())?
    var showStep: ((_ fromTag: Int, _ toTag: Int, _ fireTag: Int) -> ())?
    
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
        case .wait:
            print("wait state")
        case .finish:
            print("finish state")
        case .load:
            
            loadLocalData()
            
        }
    }
    
    var players: [Player] = []
    
    func loadGame() {
        addPlayers()
        state = .load
    }
    
    func startGame() {
        
        state = .play
        nextPlayer()
    }
    
    func addPlayers(){
        players.removeAll()
        let colors: [ChessColor] = [.white, .black]
        
        for color in colors {
            let player = Player(name: "Player \(color.rawValue)", color: color)
            players.append(player)
        }
    }
    
    func changeGameState(to state: GameState) {
        self.state = state
    }
    
    func initialNewGame(){
        durationTime = 0
        fillArrayForStartPosition()
    }
    
    func loadLocalData() {
        
        guard let savedArray = Settings.shared.chessArray else {
            initialNewGame()
            return
        }
        
        chessArray = savedArray
        durationTime = Settings.shared.gameTimeInSeconds
        if players.first?.color != Settings.shared.currentStep {
            players.swapAt(0, 1)
        }
        
    }
    
    func nextPlayer() {
        currentStep = players.removeFirst()
        guard let currentStep = self.currentStep else {return}
        players.append(currentStep)
        playerChanged?()
    }
    
    
    func isFinishGame() -> Bool{
        guard let _ = chessArray.first(where: {$0 > 0}), let _ = chessArray.first(where: {$0 < 0}) else {return true}
        return false
    }
    
    var currentStep: Player? {
        didSet{
            //  printBordersIfCanStep()
            //   fireStepArray = nil
        }
        willSet{
            if isFinishGame() {
                print("FINISH GAME")
            }
        }
    }
    
    func fillArrayForStartPosition(){
        chessArray = Array(repeating: 0, count: Int(BOARD_SIZE*BOARD_SIZE / 2))
        for i in 0..<(BOARD_SIZE/2-1)*BOARD_SIZE/2 {
            chessArray[i] = ChessType.white.rawValue
            chessArray[chessArray.count - (i + 1)] = ChessType.black.rawValue
        }
    }
    
    func saveGame(){
        Settings.shared.chessArray = chessArray
        Settings.shared.currentStep = currentStep?.color ?? .white
       // Settings.shared.gameTimeInSeconds = gameTimeInSeconds
    }
    
    
    func getChessType(by tag: Int) -> ChessType? {
        if let index = getIndexByTag(tag){
            let value = chessArray[index]
            return ChessType(rawValue: value)
        }
        return nil
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
    
    func getTagsByCurrrentColor() -> [Int] {
        getTags(by: currentStep!.color)
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
                    if chessType == .blackQueen || chessType == .whiteQueen {
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
            if type.isQueen() {
                while getChessType(by: nextTag + direction.rawValue) == ChessType.none {
                    nextTag += direction.rawValue
                }
            }
            
            if checkFireBy(tag: nextTag, in: direction, for: type) {
                let newTag = nextTag + 2 * direction.rawValue
                let newDirections = direction.otherDirections()
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
            } else {
                
            }
        }
        if !newArray.isEmpty, countDirection == 0 {
            fireStepArray.append(newArray)
        }
    }
    
    
    var continueArray = [FireStep]()
    
    func isQueenZoneBy(index: Int) -> Bool {
        if index < BOARD_SIZE/2 || index >= ((BOARD_SIZE * BOARD_SIZE)/2 - BOARD_SIZE/2) {
            return true
        }
        return false
    }
    
    func startStep(fromTag: Int, toTag: Int) {
        continueArray.removeAll()
        guard let fromIndex = getIndexByTag(fromTag),
              let toIndex = getIndexByTag(toTag) else {return}
        showStep?(fromTag, toTag, 0)
        chessArray.swapAt(fromIndex, toIndex)
        
        
        if isQueenZoneBy(index: toIndex), getChessType(by: toTag)?.isQueen() == false {
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
//                        let fireTag = step.toTag + getDirection(by: step).rawValue
//                        continueArray.append(FireStep(fromTag: -1 * fireTag, toTag: -1 * fireTag))
//
                        if let toIndex = getIndexByTag(step.toTag) {
                            if isQueenZoneBy(index: toIndex), getChessType(by: step.toTag)?.isQueen() == false {
                                continueArray.append(FireStep(fromTag: toTag, toTag: toTag))
                            }
                        }
                    } else {
                        continueArray.append(FireStep(fromTag: step.fromTag, toTag: step.toTag))
                        if let toIndex = getIndexByTag(step.toTag) {
                            if isQueenZoneBy(index: toIndex), getChessType(by: step.toTag)?.isQueen() == false {
                                continueArray.append(FireStep(fromTag: step.toTag, toTag: step.toTag))
                            }
                        }
                    }
                    let fireTag = step.toTag + getDirection(by: step).rawValue
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
                
                showStep?(nextStep.toTag, nextStep.toTag, 0)
            }
            else {
                chessArray.swapAt(fromIndex, toIndex)
                showStep?(nextStep.fromTag, nextStep.toTag, 0)
            }
        }
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


