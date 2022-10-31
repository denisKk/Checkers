//
//  GameViewController.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit

final class GameViewController: UIViewController {
    
    @IBOutlet var topPlayerView: UserPanelView!
    @IBOutlet var bottomPlayerView: UserPanelView!
    @IBOutlet var chessboardView: UIView!
    
    let game = Game.shared
    
    var animationTimer = Timer()
    var animationsArray: [AnimationItem] = [] {
        didSet {
            startAnimationTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        setupUI()
        game.loadGame()
        createChessBoard()
        createAnimationArray()
        
        
        game.playerChanged = { [weak self] in
            self?.printBordersIfCanStep()
        }
        
        game.showMessage =  { [weak self] messageType, playerName in
            
            switch messageType {
            case .draw :
                self?.showAgreeAlert(playerName: playerName ?? "")
            case .winner:
                self?.showFinishGameAlertWith(winnerName: playerName)
            }
          
        }
        
        game.showStep = { [weak self] fromTag, toTag in
            guard let self = self,
                  let fromView = self.chessboardView.viewWithTag(abs(fromTag)),
                  let toView = self.chessboardView.viewWithTag(abs(toTag)),
                  let chessView = fromView.subviews.first(where: {$0 as? ChessView != nil}) as? ChessView
            else {
                self?.game.nextStep()
                return
            }
            
            if fromTag == toTag {
                if fromTag > 0 {
                    guard !chessView.isQueen else {
                        self.game.nextStep()
                        return
                    }
                    chessView.isQueen = true
                    UIView.transition(with: toView, duration: 0.5, options: .transitionFlipFromLeft, animations: {chessView.showIn(view: toView)}) { _ in
                        self.game.nextStep()
                    }
                } else {
                    UIView.transition(with: toView, duration: 0.4, options: .transitionFlipFromLeft, animations: {chessView.removeFromSuperview()}) { _ in
                        self.game.nextStep()
                    }
                }
            }
            else {
                self.chessboardView.bringSubviewToFront(fromView)
                let xPos = (fromView.frame.origin.x + chessView.center.x) - toView.center.x
                let yPos = (fromView.frame.origin.y + chessView.center.y) - toView.center.y
                
                UIView.animate(withDuration: 0.45) {
                    chessView.center.x -= xPos
                    chessView.center.y -= yPos
                } completion: { _ in
                    chessView.showIn(view: toView)
                    self.game.nextStep()
                }
            }
        }
        
        setupPlayerPanels()
    }
    
    
    @IBAction func backButtonTap(_ sender: Any) {
        game.saveGame()
        goBack()
    }
    
    func goBack(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setupPlayerPanels(){
        if let topPlayer = game.getPlayerBy(color: .black) {
            topPlayerView.setupWith(player: topPlayer)
            topPlayerView.isFlipped = true
        }
        if let bottomPlayer = game.getPlayerBy(color: .white) {
            bottomPlayerView.setupWith(player: bottomPlayer)
        }
    }
    
    
    func startRematch(){
        game.rematchGame()
        setupPlayerPanels()
        createAnimationArray()
    }
    
    deinit{
        animationTimer.invalidate()
    }
}

//MARK: Setup elements
extension GameViewController {
    
    func setupUI(){
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }

}

//MARK: Functions
extension GameViewController {
    
    func createChessBoard(){
        let cellWidth = chessboardView.frame.width / Double(BOARD_SIZE)
        var isBlack = true
        
        for i in 0..<BOARD_SIZE {
            for j in 0..<BOARD_SIZE {
                let frame = CGRect(x: Double(i) * cellWidth, y: chessboardView.frame.width - Double(j)*cellWidth - cellWidth, width: cellWidth, height: cellWidth)
                let cellView = UIView(frame: frame)
                cellView.tag = (j * BOARD_SIZE + i + 1)
                cellView.backgroundColor = (isBlack) ? BoardCellColor.black.rawWalue : BoardCellColor.white.rawWalue
                isBlack.toggle()
                chessboardView.addSubview(cellView)
            }
            isBlack.toggle()
        }
    }
    
    func printBordersIfCanStep() {
        
        chessboardView.subviews.forEach { view in
            if let chessView = view.subviews.first as? ChessView {
                chessView.border(show: false)
            }
        }
        
        guard let arrayTags = game.getTagsForBorders() else {
            return
        }
        
        for tag in arrayTags {
            if let chessView = chessboardView.viewWithTag(tag)?.subviews.first as? ChessView {
                chessView.border(show: true)
            }
        }
    }
    
    func printCellsIfCanStep(for tag: Int, show: Bool = true){
        
        guard let array = game.getTagsToCanStep(tag: tag) else {return}
        
        if show {
            array.forEach { tag in
                if let view = chessboardView.viewWithTag(tag){
                    let lightView = UIView()
                    lightView.frame = view.bounds
                    lightView.backgroundColor = .green.withAlphaComponent(0.1)
                    view.addSubview(lightView)
                }
            }
        } else {
            array.forEach { tag in
                if let view = chessboardView.viewWithTag(tag){
                    view.subviews.forEach({$0.removeFromSuperview()})
                }
            }
        }
    }
}

//MARK: Actions
extension GameViewController {
    
    @objc
    func didPan(_ sender: UIPanGestureRecognizer){
        guard
            let pannableView = sender.view as? ChessView,
            let cellView = pannableView.superview,
            game.currentStep?.color == pannableView.type.getChessColor()
        else {return}
        
        switch sender.state {
            
        case .began:
            
            chessboardView.bringSubviewToFront(cellView)
            
            printCellsIfCanStep(for: cellView.tag)
            
            pannableView.center = sender.location(in: cellView)
        case .changed:
            pannableView.center = sender.location(in: cellView)
        case .ended,
                .cancelled:
            printCellsIfCanStep(for: cellView.tag, show: false)
            
            if let view = getCellViewBy(location: sender.location(in: chessboardView)),
               view.subviews.isEmpty, let canStepArray = game.getTagsToCanStep(tag: cellView.tag),
               canStepArray.contains(view.tag)
            {
                game.startStep(fromTag: cellView.tag, toTag: view.tag)
            }
            else {
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseInOut]) {
                    pannableView.center = CGPoint(x : cellView.frame.width / 2, y: cellView.frame.width / 2)
                }
            }
        default:
            break
        }
    }
    
    
    func getCellViewBy(location: CGPoint) -> UIView? {
        for view in chessboardView.subviews {
            if view.frame.contains(location) {
                return view
            }
        }
        return nil
    }
    
    
    func showAgreeAlert(playerName: String) {
        let alert = UIAlertController(title: "A draw".localized + "?", message: "\(playerName) " + "offers a draw. Are you agree?".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Agree".localized, style: .default, handler: { _ in
            self.game.isDraw(agree: true)
        }))
        alert.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: { _ in
            self.game.isDraw(agree: false)
        }))
        var angle = 0.0
        if bottomPlayerView.player?.name == playerName {
            angle = 90.0
        }
        
        alert.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2) * angle )
        self.present(alert, animated: false, completion: nil)

    }
    
     func showFinishGameAlertWith(winnerName: String?){
         
         let message = winnerName == nil ? "Game played to a draw".localized : "\(winnerName ?? "") " + "is winner".localized
        
         let alert = UIAlertController(title: "Finish game".localized, message: message + "!", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "Exit".localized, style: .default, handler: { _ in
            self.goBack()
        }))
         alert.addAction(UIAlertAction(title: "Rematch".localized, style: .default, handler: { _ in
            self.startRematch()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}




//MARK: Animations
struct AnimationItem {
    var index: Int
    var value: Int
}

extension GameViewController {
    // Timer for step animation
    func startAnimationTimer(){
        guard animationTimer.isValid == false else {
            return
        }
        animationTimer = Timer.scheduledTimer(timeInterval: 0.14, target: self, selector: #selector(stepAnimation), userInfo: nil, repeats: true)
    }
    
    
    @objc func stepAnimation(){
        guard !animationsArray.isEmpty else {
            animationTimer.invalidate()
            if game.state == .load {
                game.changeGameState(to: .start)
            }
            return
        }
        let animationItem = animationsArray.removeFirst()
        
        guard let cellView = chessboardView.viewWithTag(getTagByIndex(animationItem.index)),
              let type = ChessType(rawValue: animationItem.value)
        else {return}
        
        if animationItem.value != 0 {
            let chessView = ChessView(
                width: cellView.frame.width,
                type: type
            )
            chessView.isQueen = animationItem.value > 1 || animationItem.value < -1
            
            UIView.transition(with: cellView, duration: 1, options: .transitionFlipFromLeft, animations: {chessView.showIn(view: cellView)})
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            
            chessView.addGestureRecognizer(panGestureRecognizer)
        } else {
            UIView.transition(with: cellView, duration: 1, options: .transitionFlipFromLeft, animations: {cellView.subviews.forEach{$0.removeFromSuperview()}})
        }
        
    }
    
    func createAnimationArray(){
        let array = game.chessArray
        for (i, value) in array.enumerated() {
            
            guard let oneView = chessboardView.viewWithTag(getTagByIndex(i)) else {return}
            let temp: Int
            if let chessView = oneView.subviews.first as? ChessView {
                temp = chessView.type.rawValue
            } else {
                temp = 0
            }
            if temp != value {
                animationsArray.append(AnimationItem(index: i, value: value))
            }
        }
    }
    
}
