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
    
    
    private var chessArray: [Int] = []
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
    
    var isStartGameLoading = false
    
    var currentStep: ChessColor = .white {
        didSet{
            printBordersIfCanStep()
        }
        willSet{
            if isFinishGame() {
                finishGame()
            }
        }
    }
    
    func isFinishGame() -> Bool{
        guard let _ = chessArray.first(where: {$0 > 0}), let _ = chessArray.first(where: {$0 < 0}) else {return true}
        return false
    }
    
    private var fireStepArray: [FireStep] = []
    private var canStepTagsArray: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
    
    func fillArrayForStartPosition(){
        chessArray = Array(repeating: 0, count: Int(BOARD_SIZE*BOARD_SIZE / 2))
        for i in 0..<(BOARD_SIZE/2-1)*BOARD_SIZE/2 {
            chessArray[i] = ChessType.white.rawValue
            chessArray[chessArray.count - (i + 1)] = ChessType.black.rawValue
        }
    }
    
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
        if let time = Settings.shared.gameTimeInSeconds {
            gameTimeInSeconds = time
        }
        
        userNameLabel.text = Settings.shared.userName
        avatarImageView.image = Settings.shared.avatar
        
        
        if let array = Settings.shared.chessArray {
            chessArray = array
        } else {
            fillArrayForStartPosition()
        }
        
        currentStep = Settings.shared.currentStep
        
        if let gradient = Settings.shared.gradientColor {
            if let view = self.view as? GradientBackgroundView {
                view.setGradientColor(gradient: gradient)
            }
        }
    }
    
    func resetGame(){
        gameTimer.invalidate()
        gameTimeInSeconds = 0
        Settings.shared.resetData()
        fillArrayForStartPosition()
        currentStep = .white
        createAnimationArray()
    }
    
    func saveGame(){
        Settings.shared.chessArray = chessArray
        Settings.shared.currentStep = currentStep
        Settings.shared.gameTimeInSeconds = gameTimeInSeconds
    }
    
    func finishGame() {
        gameTimer.invalidate()
        Settings.shared.resetData()
        showFinishGameAlert()
    }
    
    
    func getTagByIndex(_ index: Int) -> Int{
        let row = ((index + 1) % (BOARD_SIZE/2) == 0) ? (index + 1) / (BOARD_SIZE/2) : (index + 1) / (BOARD_SIZE/2) + 1
        return (row % 2 == 0) ? (index + 1) * 2 : ((index + 1) * 2) - 1
    }
    
    func getIndexByTag(_ tag: Int) -> Int?{
        guard tag <= BOARD_SIZE*BOARD_SIZE && tag > 0 else {return nil}
        let row = (tag % BOARD_SIZE == 0) ? tag / BOARD_SIZE : tag / BOARD_SIZE + 1
        return (row % 2 == 0) ? (tag % 2 == 0 ? ((tag / 2) - 1) : nil) : (tag % 2 == 0 ? nil : (((tag + 1) / 2) - 1))
    }
    
    func getChessType(by tag: Int) -> ChessType? {
        if let index = getIndexByTag(tag){
            let value = chessArray[index]
            return ChessType(rawValue: value)
        }
        return nil
    }
    
    func getDirection(by fireStep: FireStep) -> Direction {
        let delta = fireStep.fromTag - fireStep.toTag
        if delta > 0 {
            if delta % 7 == 0 {
                return .topLeft
            }
            else {
                return .topRight
            }
        }
        else {
            if delta % 9 == 0 {
                return .bottomLeft
            }
            else {
                return .bottomRight
            }
        }
    }
    
    func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            gameTimeInSeconds += 1
        })
    }
    
    func printBordersIfCanStep() {
        guard let arrayIndexes = checkForMustFire(), arrayIndexes.isEmpty == false else {
            for (index, value) in chessArray.enumerated() {
                if value != 0,
                   let chessView = chessboardView.viewWithTag(getTagByIndex(index))?.subviews.first as? ChessView {
                    chessView.border(show: currentStep == chessView.color)
                }
            }
            return
        }
        
        for (index, value) in chessArray.enumerated() {
            if value != 0,
               let chessView = chessboardView.viewWithTag(getTagByIndex(index))?.subviews.first as? ChessView {
                
                if arrayIndexes.contains(index) {chessView.border(show: true)}
                else {chessView.border(show: false)}
            }
        }
    }
    
    func checkForMustFire() -> [Int]? {
        var arrayIndexes: [Int] = []
        for (index, value) in chessArray.enumerated() {
            if let chessType = ChessType(rawValue: value),
               chessType != .none, chessType.getChessColor() == currentStep
            {
                for direction in Direction.allDirections {
                    if checkFireBy(tag: getTagByIndex(index), in: direction, for: chessType) {
                        arrayIndexes.append(index)
                    }
                }
            }
        }
        return arrayIndexes.isEmpty ? nil : arrayIndexes
    }
    
    func getFireSteps(for tag: Int, directions: [Direction], type: ChessType) {
        for direction in directions {
            
            var nextTag = tag
            if type.isQueen() {
                while getChessType(by: nextTag + direction.rawValue) == ChessType.none {
                    nextTag += direction.rawValue
                }
            }
            
            if checkFireBy(tag: nextTag, in: direction, for: type) {
                let newTag = nextTag + 2 * direction.rawValue
                let newDirections = direction.otherDirections()
                fireStepArray.append(FireStep(fromTag: tag, toTag: newTag))
                var newType = type
                if type == .white && newTag > (BOARD_SIZE * BOARD_SIZE - BOARD_SIZE) {
                    newType = ChessType.whiteQueen
                }
                
                if type == .black && newTag <= BOARD_SIZE {
                    newType = ChessType.blackQueen
                }
                
                getFireSteps(for: newTag, directions: newDirections, type: newType)
            }
        }
    }
    
    func checkStepBy(tag: Int, direction: Direction) -> Bool {
        return getChessType(by: tag + direction.rawValue) == ChessType.none ? true : false
    }
    
    func checkFireBy(tag: Int, in direction: Direction, for chessType: ChessType) -> Bool {
        
        guard chessType.isQueen() else
        {
            if let firstType = getChessType(by: tag + direction.rawValue),
               firstType.isOpponent(for: chessType),
               getChessType(by: tag + 2 * direction.rawValue) == ChessType.none
            {
                return true
            }
            
            return false
        }
        
        var newTag = tag + direction.rawValue
        while getChessType(by: newTag) == ChessType.none {
            newTag += direction.rawValue
        }
        
        if let firstType = getChessType(by: newTag),
           firstType.isOpponent(for: chessType),
           getChessType(by: newTag + direction.rawValue) == ChessType.none
        {
            return true
        }
        
        
        return false
    }
    
    func doFireFrom(startTag: Int){
        doBackFire(tag: startTag)
        doNextFire(tag: startTag)
    }
    
    func doNextFire(tag: Int){
        guard let fire = fireStepArray.first(where: {$0.fromTag == tag}) else {
            fireStepArray.removeAll()
            currentStep.toggle()
            return
        }
        
        
        
        let fireTag = fire.toTag + getDirection(by: fire).rawValue
        
        guard let fromView = chessboardView.viewWithTag(tag),
              let toView = chessboardView.viewWithTag(fire.toTag),
              let chessView = fromView.subviews.first(where: {$0 as? ChessView != nil}) as? ChessView
        else {return}
        
        chessboardView.bringSubviewToFront(fromView)
        
        let xPos = fromView.frame.origin.x - toView.frame.origin.x
        let yPos = fromView.frame.origin.y - toView.frame.origin.y
        
        UIView.animate(withDuration: 0.5) {
            chessView.center.x -= xPos
            chessView.center.y -= yPos
        } completion: { _ in
            chessView.showIn(view: toView) {
                //
            }
            guard let fireIndex = self.getIndexByTag(fireTag),
                  let fromIndex = self.getIndexByTag(fire.fromTag),
                  let toIndex = self.getIndexByTag(fire.toTag)
            else {return}
            
            self.chessArray.replaceIndexes(fromIndex: fromIndex, toIndex: toIndex)
            if (self.chessArray[toIndex] > 1 || self.chessArray[toIndex] < -1) && chessView.isQueen == false {
                self.animationsArray.append(AnimationItem(index: toIndex, value: self.chessArray[toIndex]))
            }
            self.chessArray[fireIndex] = ChessType.none.rawValue
            self.animationsArray.append(AnimationItem(index: fireIndex, value: ChessType.none.rawValue))
            
            self.doNextFire(tag: fire.toTag)
        }
    }
    
    
    func doBackFire(tag: Int) {
        if let fire = fireStepArray.first(where: {$0.toTag == tag}) {
            let fireTag = fire.toTag + getDirection(by: fire).rawValue
            if let fireIndex = getIndexByTag(fireTag) {
                chessArray[fireIndex] = ChessType.none.rawValue
                animationsArray.append(AnimationItem(index: fireIndex, value: ChessType.none.rawValue))
            }
            doBackFire(tag: fire.fromTag)
        }
    }
}

//MARK: Actions
extension GameViewController {
    @objc
    func didPan(_ sender: UIPanGestureRecognizer){
        guard
            let pannableView = sender.view as? ChessView,
            let superView = pannableView.superview,
            currentStep == pannableView.color
        else {return}
        
        switch sender.state {
            
        case .began:
            
            chessboardView.bringSubviewToFront(superView)
            
            if gameTimer.isValid == false {
                startTimer()
            }
            
            let tag = superView.tag
            if let type = getChessType(by: tag) {
                if let _ = checkForMustFire() {
                    getFireSteps(for: tag, directions: Direction.allDirections, type: type)
                    fireStepArray.forEach { fireStep in
                        canStepTagsArray.append(fireStep.toTag)
                    }
                } else {
                    let directions =  type.getDirections()
                    for direction in directions {
                        if checkStepBy(tag: tag, direction: direction)
                        {
                            if type == .blackQueen || type == .whiteQueen {
                                var newTag = tag + direction.rawValue
                                while checkStepBy(tag: newTag, direction: direction) {
                                    newTag += direction.rawValue
                                    canStepTagsArray.append(newTag)
                                    
                                }
                            }
                            canStepTagsArray.append(tag + direction.rawValue)
                        }
                    }
                }
            }
            
            
            
            canStepTagsArray.forEach { tag in
                if let view = chessboardView.viewWithTag(tag){
                    let lightView = UIView()
                    lightView.frame = view.bounds
                    lightView.backgroundColor = .green.withAlphaComponent(0.1)
                    view.addSubview(lightView)
                }
            }
            
            pannableView.center = sender.location(in: superView)
        case .changed:
            pannableView.center = sender.location(in: superView)
        case .ended,
                .cancelled:
            
            canStepTagsArray.forEach { tag in
                if let view = chessboardView.viewWithTag(tag){
                    view.subviews.forEach({$0.removeFromSuperview()})
                }
            }
            var isMove = false
            
            for view in chessboardView.subviews {
                if view.frame.contains(sender.location(in: chessboardView)),
                   view.subviews.isEmpty,
                   canStepTagsArray.contains(view.tag)
                {
                    isMove = true
                    if let fromIndex = getIndexByTag(superView.tag),
                       let toIndex = getIndexByTag(view.tag)
                    {
                        chessArray.replaceIndexes(fromIndex: fromIndex, toIndex: toIndex)
                        pannableView.showIn(view: view, onCompletion: nil)
                        if (self.chessArray[toIndex] > 1 || self.chessArray[toIndex] < -1) && pannableView.isQueen == false {
                            
                            animationsArray.append(AnimationItem(index: toIndex, value: chessArray[toIndex]))
                         //   pannableView.isQueen = true
                        }
                        
                        if !fireStepArray.isEmpty {
                            doFireFrom(startTag: view.tag)
                        } else {
                            currentStep.toggle()
                        }
                    }
                }
            }
            
            
            canStepTagsArray.removeAll()
            
            if !isMove {
                fireStepArray.removeAll()
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseInOut]) {
                    pannableView.center = CGPoint(x : superView.frame.width / 2, y: superView.frame.width / 2)
                }
            }
        default:
            break
        }
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
            self.saveGame()
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
        let winnerColor = currentStep.rawValue.uppercased()
        let alert = UIAlertController(title: "Finish game", message: winnerColor + " is winner!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Super", style: .default, handler: { action in
            self.goBack()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


//MARK: Notifications
extension GameViewController {
    //    func sendChangeLastStepNotification(){
    //        let nowColorStep: ChessColor = isLastStepWhite ? .black : .white
    //        let infoDataDict:[String: ChessColor] = ["nowColorStep": nowColorStep]
    //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_CHANGE_LAST_STEP), object: nil, userInfo: infoDataDict)
    //    }
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
        animationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(stepAnimation), userInfo: nil, repeats: true)
    }
    
    
    @objc func stepAnimation(){
        guard animationsArray.isEmpty == false else {
            animationTimer.invalidate()
            if isStartGameLoading {
                isStartGameLoading = false
                printBordersIfCanStep()
            }
            return
        }
        let animationItem = animationsArray.removeFirst()
        
        guard let oneView = chessboardView.viewWithTag(getTagByIndex(animationItem.index)) else {return}
        
        if animationItem.value != 0 {
            let cView = ChessView(
                width: oneView.frame.width,
                color: animationItem.value > 0 ? .white : .black
            )
          //  cView.isQueen = animationItem.value > 1 || animationItem.value < -1
            
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            
            cView.addGestureRecognizer(panGestureRecognizer)
        } else {
            UIView.transition(with: oneView, duration: 1, options: .transitionFlipFromLeft, animations: {oneView.subviews.forEach{$0.removeFromSuperview()}})
        }
        
    }
    
    func createAnimationArray(){
        isStartGameLoading = true
        for (i, value) in chessArray.enumerated() {
            
            guard let oneView = chessboardView.viewWithTag(getTagByIndex(i)) else {return}
            let temp: Int
            if let chessView = oneView.subviews.first as? ChessView {
                temp = chessView.color == .white ? ChessType.white.rawValue : ChessType.black.rawValue
            } else {
                temp = 0
            }
            if temp != value {
                animationsArray.append(AnimationItem(index: i, value: value))
            }
        }
    }
    
}

//MARK: Logic extention

//extension Int {
//    func deltaArray(by value: Int) -> [Int] {
//        switch self {
//        case 0, 7:
//            return [4 * value]
//        case 1...3:
//            return (value > 0) ? [3, 4] : [-4, -5]
//        case 4...6:
//            return (value > 0) ? [4, 5] : [-3, -4]
//        default:
//            return []
//        }
//    }
//}

//extension Array where Element == Int {
//    func findStepsBy(index: Int) -> [Int] {
//        let currentValue = self[index]
//
//        var array: [Int] = []
//        (index % 8).deltaArray(by: currentValue).forEach { value in
//            if self[index + value] == 0 {
//                array.append(index + value)
//            }
//        }
//
//        return array
//    }
//}

