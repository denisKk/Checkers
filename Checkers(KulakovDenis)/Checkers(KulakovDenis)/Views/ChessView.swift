//
//  chessView.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit

enum ChessColor: String {
    typealias ColorValue = UIColor
    
    case white
    case black
    
    var cgColor: ColorValue {
        switch self {
        case .white:
            return #colorLiteral(red: 0.8491786718, green: 0.9070555568, blue: 0.9816407561, alpha: 1)
        case .black:
            return #colorLiteral(red: 0.1176470588, green: 0.1215686275, blue: 0.1490196078, alpha: 1)
        }
    }
    
    mutating func toggle(){
        switch self {
        case .white:
            self = .black
        case .black:
            self = .white
        }
    }
}

class ChessView: UIView {

    var color: ChessColor
    var isQueen = false {
        didSet {
            if oldValue == false && isQueen {
                showQueen()
            }
        }
    }
    
    init(width: CGFloat, color: ChessColor) {
        self.color = color
        let scale = 0.7
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width * scale, height: width * scale)))
        self.backgroundColor = color.cgColor
        self.layer.cornerRadius = width * scale / 2
        self.layer.borderWidth = 0
        let alpha = (color == .white) ? 1 : 0.3
        self.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).withAlphaComponent(alpha).cgColor
//        NotificationCenter.default.addObserver(self, selector: #selector(changeLastStep(_:)), name: NSNotification.Name(NOTIFICATION_CHANGE_LAST_STEP), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showQueen() {
        let imageView = UIImageView(frame: self.bounds)
        var imageColor = self.color
        imageColor.toggle()
        imageView.image = UIImage(systemName: "crown")
        imageView.tintColor = imageColor.cgColor.withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    func showIn(view: UIView, showQueen: Bool = false, onCompletion: (() -> ())?) {
        view.subviews.forEach({$0.removeFromSuperview()})
        view.addSubview(self)
        self.center = CGPoint(x: view.frame.width / 2, y: view.frame.width / 2)
        onCompletion?()
    }
    
    func hide(){
        self.removeFromSuperview()
    }
    
    func border(show: Bool){
        self.layer.borderWidth = show ? 2 : 0
    }
    
    
    
//    @objc
//    private func changeLastStep(_ notification: NSNotification){
//        if let color = notification.userInfo?["nowColorStep"] as? ChessColor {
//            self.layer.borderWidth = self.color == color ? 2 : 0
//            let alpha = (color == .white) ? 1 : 0.3
//
//            self.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).withAlphaComponent(alpha).cgColor
//          }
//    }
}
