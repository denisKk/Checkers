//
//  Constants.swift
//  Checkers(kulakov)
//
//  Created by Dev on 31.01.22.
//
import UIKit

var BOARD_SIZE: Int {
    get { Settings.shared.boardSize.rawValue }
}
var SCREEN_WIDTH: CGFloat {
    return UIScreen.main.bounds.width
}
var SCREEN_HEIGHT: CGFloat {
    return UIScreen.main.bounds.height
}

