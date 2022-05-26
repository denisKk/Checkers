//
//  File.swift
//  Checkers(kulakov)
//
//  Created by Dev on 4.02.22.
//

import Foundation


extension Array where Element == Int {
    mutating func replaceIndexes(fromIndex: Int, toIndex: Int){
        
        var temp = self[fromIndex]
        
        if temp == 1 && toIndex >= self.count - 4 {
            temp += 1
        }
        
        if temp == -1 && toIndex < 4 {
            temp -= 1
        }
        
        self[fromIndex] = self[toIndex]
        self[toIndex] = temp
//        print(self)
    }
}
