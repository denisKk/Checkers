//
//  Settings.swift
//  Kinopoisk
//
//  Created by Dev on 2.02.22.
//

import Foundation
import UIKit

class Settings: NSObject {
    
    static let shared = Settings()
    
    enum UserDefaultsKeys: String {
        case userName
        case chessArray
        case avatar
        case currentStep
        case gameTimeInSeconds
        case startGradientColor
        case endGradientColor
    }
    
   
    
    override init() {
        isEmptyAvatar = UserDefaults.standard.data(forKey: UserDefaultsKeys.avatar.rawValue) == nil
        super.init()
    }
    
    var userName: String? {
        get{
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userName.rawValue)
        }
    }
    
    var chessArray: [Int]? {
        get{
            return UserDefaults.standard.array(forKey: UserDefaultsKeys.chessArray.rawValue) as? [Int] ?? nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.chessArray.rawValue)
        }
    }
    
    func resetData(){
        //    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userName.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.gameTimeInSeconds.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentStep.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.chessArray.rawValue)
    }
    
    var isEmptyAvatar: Bool
    var avatar: UIImage? {
        get{
            
            if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.avatar.rawValue) {
                return UIImage(data: data)
            }
            return UIImage(named: "avatar")
        }
        set {
            isEmptyAvatar = newValue == nil
            if let data = newValue?.jpegData(compressionQuality: 0.96) {
                UserDefaults.standard.set(data, forKey: UserDefaultsKeys.avatar.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.avatar.rawValue)
            }
        }
    }
    
    var currentStep: ChessColor {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.currentStep.rawValue)
        }
        
        get {
            guard let savedColor =  UserDefaults.standard.string(forKey: UserDefaultsKeys.currentStep.rawValue) else {
                return .white
            }
            return ChessColor.init(rawValue: savedColor) ?? .white
        }
    }
    
    var gameTimeInSeconds: Int? {
        set {
            if let seconds = newValue {
                UserDefaults.standard.set(seconds, forKey: UserDefaultsKeys.gameTimeInSeconds.rawValue)
                print("Save time \(seconds)")
            }
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKeys.gameTimeInSeconds.rawValue)
        }
    }
    
    var gradientColor: (UIColor, UIColor)? {
        set {
            if let gColor = newValue {
                
                if let first : Data = try? NSKeyedArchiver.archivedData(withRootObject: gColor.0, requiringSecureCoding: false) as Data {
                    UserDefaults.standard.set(first, forKey: UserDefaultsKeys.startGradientColor.rawValue)
                }
                if let second : Data = try? NSKeyedArchiver.archivedData(withRootObject: gColor.1, requiringSecureCoding: false) as Data {
                    UserDefaults.standard.set(second, forKey: UserDefaultsKeys.endGradientColor.rawValue)
                }
                UserDefaults.standard.synchronize()
            }
        }
        get {
            guard
                let first = UserDefaults.standard.data(forKey: UserDefaultsKeys.startGradientColor.rawValue),
                let unarchivedFirst = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: first),
                let firstColor = unarchivedFirst as UIColor?
            else {
                return nil
            }
            
            guard
                let second = UserDefaults.standard.data(forKey: UserDefaultsKeys.endGradientColor.rawValue),
                let unarchivedSecond = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: second),
                let secondColor = unarchivedSecond as UIColor?
            else {
                return nil
            }
            
            return (firstColor, secondColor)
        }
    }
}
