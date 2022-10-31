//
//  UILabel.swift
//  Checkers(kulakov)
//
//  Created by Dev on 16.02.22.
//

import Foundation
import UIKit

extension UILabel {
    func setButtonModifier() {
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: "Montserrat", size: 24)
    }

    func setTitleModifier() {
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: "Montserrat-Thin", size: 30)
    }

    func size(width: Double, height: Double) {
        self.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
    }

    @IBInspectable var localizationKey: String {
        get {
            return self.text ?? ""
        }
        set {
            self.text = newValue.localized
        }
    }
}
