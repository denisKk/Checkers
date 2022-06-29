//
//  UserPanelView.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 23.06.22.
//

import UIKit

class UserPanelView: UIView {

    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var flagButton: BorderButton!
    @IBOutlet weak var handsButton: BorderButton!
    var isFlipped: Bool = false {
        didSet {
            if isFlipped {
                rotateContentView()
            }
        }
    }
    
    var isActive: Bool = false {
        didSet {
            configurateView()
        }
    }
    
    var player: Player? {
        didSet {
            userName.text = player?.name
            timeLabel.text = player?.time.secondsToString()
        }
    }
    
    private func configurateView(){
        if isActive {
            contentView.layer.borderWidth = 2
            flagButton.isEnabled = true
            handsButton.isEnabled = true
        } else {
            contentView.layer.borderWidth = 0
            flagButton.isEnabled = false
            handsButton.isEnabled = false
        }
    }
    
    func setupWith(player: Player){
        self.player = player
        
        
        player.didActivityChanged = {
            self.isActive = player.isActive
        }
        player.didTimeChanged = {
            self.timeLabel.text = player.time.secondsToString()
        }
        
    }
    
    func rotateContentView(){
        contentView.transform = CGAffineTransform(rotationAngle: 180 * .pi/180);
    }
    
    func initFromNib() -> UIView? {
        return UINib(nibName: "UserPanelView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    
    @objc
    func tapflagButton(){
        guard player?.result == PlayerResult.none,
              flagButton.isEnabled
        else {return}
        player?.result = .abort
    }
    
    @objc
    func tapHandsButton() {
        guard player?.result == PlayerResult.none,
        handsButton.isEnabled
        else {return}
        player?.result = .draw
    }
    
    
    func commonInit(){
        guard let view = initFromNib() else {return}
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        self.addSubview(view)
        
        contentView.backgroundColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9607843137, alpha: 0.1305618791)
        contentView.layer.borderColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9607843137, alpha: 1).cgColor
        flagButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapflagButton)))
        flagButton.isEnabled = false
        handsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandsButton)))
        handsButton.isEnabled = false
    
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
