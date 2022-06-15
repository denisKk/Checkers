//
//  GameViewController.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit




class GameViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var resetButton: BorderButton!
    @IBOutlet weak var saveButton: BorderButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var chessboardView: UIView!
    
    let game = Game.shared

    var animationTimer = Timer()
    var animationsArray: [AnimationItem] = [] {
        didSet {
            startAnimationTimer()
        }
    }
    var gameTimer = Timer()
    
    private var gameTimeInSeconds: Int = 0 {
        didSet{
            let min = (gameTimeInSeconds % 3600) / 60
            let sec = (gameTimeInSeconds % 3600) % 60
            let strMin = min < 10 ? "0\(min)" : "\(min)"
            let strSec = sec < 10 ? "0\(sec)" : "\(sec)"
            timeLabel.text = strMin + ":" + strSec
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        game.loadGame()
        
        game.playerChanged = { [weak self] in
            self?.printBordersIfCanStep()
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
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        createChessBoard()
        createAnimationArray()
    }
    
    @IBAction func backButtonTap(_ sender: Any) {
        goBack()
    }
    
    func goBack(){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit{
        animationTimer.invalidate()
        gameTimer.invalidate()
    }
}

//MARK: Setup elements
extension GameViewController {
    
    func setupUI(){
        setupImageView()
        setupButtons()
        
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }
    
    func setupImageView(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    func setupButtons(){
        resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showResetAlert)))
        
        saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSaveAlert)))
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
    
    func loadData(){
        userNameLabel.text = Settings.shared.userName
        avatarImageView.image = Settings.shared.avatar
    }
    
    func resetGame(){
        gameTimer.invalidate()
        gameTimeInSeconds = 0
        //   Settings.shared.resetData()
        //    fillArrayForStartPosition()
        //    currentStep = .white
        game.initialNewGame()
        createAnimationArray()
    }
    
    func finishGame() {
        gameTimer.invalidate()
        Settings.shared.resetData()
        showFinishGameAlert()
    }

    func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            gameTimeInSeconds += 1
        })
    }
    
    func printBordersIfCanStep() {
        chessboardView.subviews.forEach { view in
            if let chessView = view.subviews.first as? ChessView {
                chessView.border(show: false)
            }
        }
//        guard let arrayTags = game.tagsForMustFire() else {
//            let array = game.getTagsByCurrrentColor()
//            for tag in array {
//                if let chessView = chessboardView.viewWithTag(tag)?.subviews.first as? ChessView {
//                    chessView.border(show: true)
//                }
//            }
//            return
//        }
        
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
        print("PRINT CELL IF CAN STEP")
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
            
            if gameTimer.isValid == false {
                startTimer()
            }
            
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
    
    
    @objc func showResetAlert(){
        let alert = UIAlertController(title: "Reset game", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
            self.resetGame()
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showSaveAlert(){
        
        let alert = UIAlertController(title: "Save game", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { action in
            self.game.saveGame()
            self.startTimer()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.startTimer()
        }))
        self.present(alert, animated: true, completion: {
            self.gameTimer.invalidate()
        })
    }
    
    @objc func showFinishGameAlert(){
        //        let winnerColor = currentStep.rawValue.uppercased()
        //        let alert = UIAlertController(title: "Finish game", message: winnerColor + " is winner!", preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "Super", style: .default, handler: { action in
        //            self.goBack()
        //        }))
        //
        //        self.present(alert, animated: true, completion: nil)
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
        animationTimer = Timer.scheduledTimer(timeInterval: 0.18, target: self, selector: #selector(stepAnimation), userInfo: nil, repeats: true)
    }
    
    
    @objc func stepAnimation(){
        guard !animationsArray.isEmpty else {
            animationTimer.invalidate()
            if game.state == .load {
                game.changeGameState(to: .start)
                // printBordersIfCanStep()
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
