//
//  Player.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 27.05.22.
//

import Foundation
import UIKit

class Player {
    var name: String
    var avatar: UIImage?
    var color: ChessColor
    
    
    init(name: String, color: ChessColor) {
        self.name = name
        self.color = color
    }
}
