//
//  CHLogic.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 26.05.22.
//

import Foundation
import UIKit

typealias FireStep = (fromTag: Int, toTag: Int)

enum Direction: Int {
    case topLeft = 7
    case topRight = 9
    case bottomLeft = -9
    case bottomRight = -7
    
    
    static var allDirections: [Direction] {
        [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }
    
    static var topDirections: [Direction] {
        [.topLeft, .topRight]
    }
    
    static var bottomDirections: [Direction] {
        [.bottomLeft, .bottomRight]
    }

    
    func otherDirections() -> [Direction] {
        Direction.allDirections.filter {$0 != self.contrDirection()}
    }
    
    func contrDirection() -> Direction {
        switch self {
        case .topLeft:
            return .bottomRight
        case .topRight:
            return .bottomLeft
        case .bottomLeft:
            return .topRight
        case .bottomRight:
            return .topLeft
        }
    }

    
}

enum BoardCellColor {
    typealias RawValue = UIColor
    
    case white
    case black
    
    var rawWalue: RawValue {
        switch self {
        case .white:
            return #colorLiteral(red: 0.3019607843, green: 0.3921568627, blue: 0.5529411765, alpha: 1)
        case .black:
            return #colorLiteral(red: 0.1568627451, green: 0.2117647059, blue: 0.3333333333, alpha: 1)
        }
    }
}

enum ChessType: Int {
    case none = 0
    case white = 1
    case whiteQueen = 2
    case black = -1
    case blackQueen = -2
    
    func isOpponent(for type: ChessType) -> Bool {
        switch self {
        case .white, .whiteQueen:
            return (type == .black || type == .blackQueen) ? true : false
        case .black, .blackQueen:
            return (type == .white || type == .whiteQueen) ? true : false
        default:   return false
        }
    }
    
    func getChessColor() -> ChessColor? {
        return self.rawValue > 0 ? .white : self.rawValue < 0 ? .black : nil
    }
    
    func getDirections() -> [Direction] {
        switch self {
        case .white:
            return Direction.topDirections
        case .black:
            return Direction.bottomDirections
        case .whiteQueen, .blackQueen:
            return Direction.allDirections
        default:   return []
        }
    }
    
    func isQueen() -> Bool {
        switch self {
        case .white, .black, .none:
            return false
        case .whiteQueen, .blackQueen:
            return true
        }
    }
}
