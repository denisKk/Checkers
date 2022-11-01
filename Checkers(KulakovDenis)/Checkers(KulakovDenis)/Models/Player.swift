//
//  Player.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 27.05.22.
//

import Foundation
import UIKit

enum PlayerResult: Int {
    case none
    case win
    case lose
    case draw
    case abort

    func image() -> UIImage? {
        switch self {
        case .none, .lose:
           return nil
        case .win:
            return UIImage(systemName: "crown")
        case .draw:
            return UIImage(named: "handshake")
        case .abort:
            return UIImage(systemName: "flag")
        }
    }
}

final class Player {
    var name: String
    var avatar: UIImage?
    var color: ChessColor
    var result: PlayerResult = .none {
        didSet {
            didResultChanged?()
        }
    }
    var isActive: Bool = false {
        didSet {
            didActivityChanged?()
        }
    }
    var time: Int {
        didSet {
            didTimeChanged?()
        }
    }

    var didActivityChanged: (() -> Void)?
    var didTimeChanged: (() -> Void)?
    var didResultChanged: (() -> Void)?

    init(name: String, color: ChessColor, time: Int) {
        self.name = name
        self.color = color
        self.time = time
    }
}
