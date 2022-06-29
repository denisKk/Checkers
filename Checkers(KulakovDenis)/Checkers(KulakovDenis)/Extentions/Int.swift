//
//  Int.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 23.06.22.
//

import Foundation

extension Int {
    func secondsToString() -> String {
        let min = (self % 3600) / 60
        let sec = (self % 3600) % 60
        let strMin = min < 10 ? "0\(min)" : "\(min)"
        let strSec = sec < 10 ? "0\(sec)" : "\(sec)"
        return strMin + ":" + strSec
    }
}
