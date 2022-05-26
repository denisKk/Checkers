//
//  UIColor.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit

extension UIColor {
    static var random: UIColor {
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
}
