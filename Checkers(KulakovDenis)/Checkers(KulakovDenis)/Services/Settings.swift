//
//  Settings.swift
//  Kinopoisk
//
//  Created by Dev on 2.02.22.
//

import Foundation
import UIKit

enum BoardSize: Int {
    case size8x8 = 8
    case size10x10 = 10
    
    func description() -> String {
        switch self {
        case .size8x8:
            return " 8x8 "
        case .size10x10:
           return " 10x10 "
        }
    }
}

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
        case boardSize
        case timeLimit
        case secondPlayerName
        case topPlayerTime
        case bottomPlayerTime
        case language
        case showAds
    }
    
    let languageCodes = ["en", "be", "ru"]
   
    
    override init() {
        isEmptyAvatar = UserDefaults.standard.data(forKey: UserDefaultsKeys.avatar.rawValue) == nil
        super.init()
    }
    
    var timeLimit: TimeType {
        get {
            return TimeType(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.timeLimit.rawValue)) ?? .unlimit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.timeLimit.rawValue)
        }
    }
    
    var boardSize: BoardSize {
        get {
            return BoardSize(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.boardSize.rawValue)) ?? .size8x8
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.boardSize.rawValue)
        }
    }
    
    var userName: String? {
        get{
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userName.rawValue)
        }
    }
    
    var secondPlayerName: String? {
        get{
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.secondPlayerName.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.secondPlayerName.rawValue)
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
    
    var showAds: Bool {
        get{
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.showAds.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.showAds.rawValue)
        }
    }
    
    func resetData(){
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.boardSize.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.timeLimit.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.topPlayerTime.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.bottomPlayerTime.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentStep.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.chessArray.rawValue)
    }
    
    func rematchData(){
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.topPlayerTime.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.bottomPlayerTime.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.chessArray.rawValue)
    }
    
    func logOut(){
        resetData()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userName.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.avatar.rawValue)
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
    
    var topPlayerTime: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.topPlayerTime.rawValue)
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKeys.topPlayerTime.rawValue)
        }
    }
    
    var bottomPlayerTime: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.bottomPlayerTime.rawValue)
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKeys.bottomPlayerTime.rawValue)
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
    
    var currentLanguageCode: String {
        set {
            if let index = languageCodes.firstIndex(of: newValue) {
                UserDefaults.standard.set(index, forKey: UserDefaultsKeys.language.rawValue)
            }
            
            if let window = UIApplication.shared.windows.first?.rootViewController?.view {
                let subviews = window.subviews

                subviews.forEach { subView in
                    subView.removeFromSuperview()
                    window.addSubview(subView)
                }
            }
        }
        
        get {
            let indexCode = UserDefaults.standard.integer(forKey: UserDefaultsKeys.language.rawValue)
            return languageCodes[indexCode]
        }
    }
}
