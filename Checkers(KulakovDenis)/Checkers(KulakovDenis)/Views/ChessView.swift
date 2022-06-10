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

  //  var color: ChessColor
    var type: ChessType
    var isQueen = false {
        didSet {
            if oldValue == false && isQueen {
                showQueen()
            }
        }
    }
    
    init(width: CGFloat, type: ChessType) {
        self.type = type
        let scale = 0.7
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width * scale, height: width * scale)))
        
        if let color = type.getChessColor() {
            self.backgroundColor = color.cgColor
            let alpha = (color == .white) ? 1 : 0.3
            self.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).withAlphaComponent(alpha).cgColor
        }
        
        self.layer.cornerRadius = width * scale / 2
        self.layer.borderWidth = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showQueen() {
        guard let cellView = self.superview, let color = self.type.getChessColor() else {
            return
        }
        
        let imageView = UIImageView(frame: self.bounds)
        var imageColor = color
        imageColor.toggle()
        imageView.image = UIImage(systemName: "crown")
        imageView.tintColor = imageColor.cgColor.withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        
        //UIView.transition(with: cellView, duration: 1, options: .transitionFlipFromLeft, animations: {
            self.addSubview(imageView)
            
       // })
    }
    
    func showIn(view: UIView, showQueen: Bool = false, onCompletion: (() -> ())? = nil) {
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

}
