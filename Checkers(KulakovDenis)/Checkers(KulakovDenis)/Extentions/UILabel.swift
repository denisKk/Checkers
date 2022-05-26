//
//  UILabel.swift
//  Checkers(kulakov)
//
//  Created by Dev on 16.02.22.
//

import Foundation
import UIKit


extension UILabel {
    func setButtonModifier(){
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: "Montserrat", size: 24)
    }
    
    func setTitleModifier(){
        self.textColor = .white
        self.textAlignment = .center
        self.font = UIFont(name: "Montserrat-Thin", size: 30)
    }
    
    func size(w: Double, h: Double){
        self.frame = CGRect(origin: .zero, size: CGSize(width: w, height: h))
    }
}
