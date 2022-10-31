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
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var rawValue: Int {
        switch self {
        case .topLeft:
            return BOARD_SIZE - 1
        case .topRight:
            return BOARD_SIZE + 1
        case .bottomLeft:
            return -1 * (BOARD_SIZE + 1)
        case .bottomRight:
            return -1 * (BOARD_SIZE - 1)
        }
    }

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

    func upgrade() -> ChessType {
        switch self {
        case .white:
            return .whiteQueen
        case .black:
            return  .blackQueen
        default: return self
        }
    }
}

func getTagByIndex(_ index: Int) -> Int {
    let row = ((index + 1) % (BOARD_SIZE/2) == 0) ?
    (index + 1) / (BOARD_SIZE/2) :
    (index + 1) / (BOARD_SIZE/2) + 1
    return (row % 2 == 0) ?
    (index + 1) * 2 :
    ((index + 1) * 2) - 1
}

func getIndexByTag(_ tag: Int) -> Int? {
    guard tag <= BOARD_SIZE*BOARD_SIZE && tag > 0 else {return nil}
    let row = (tag % BOARD_SIZE == 0) ? tag / BOARD_SIZE : tag / BOARD_SIZE + 1
    return (row % 2 == 0) ?
    (tag % 2 == 0 ? ((tag / 2) - 1) : nil) :
    (tag % 2 == 0 ? nil : (((tag + 1) / 2) - 1))
}
