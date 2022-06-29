//
//  ScoreTableViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 1.03.22.
//

import UIKit

struct ScoreItem {
    var whitePlayerName: String
    var blackPlayerName: String
    var date: String
    var time: String
    var isWhiteWin: Bool
}


class ScoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var blackCrownImage: UIImageView!
    @IBOutlet weak var blackChessImage: UIImageView!
    @IBOutlet weak var playerBlackLabel: UILabel!
    @IBOutlet weak var whiteCrownImage: UIImageView!
    @IBOutlet weak var whiteChessImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerWhiteLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var boardSize: UILabel!
    @IBOutlet weak var whiteTimeLabel: UILabel!
    
    @IBOutlet weak var blackTimeLabel: UILabel!
    var dateFormatter: DateFormatter {
       let date = DateFormatter()
        date.dateFormat = "d MMM y"
        date.locale = Locale.init(identifier: Settings.shared.currentLanguageCode)
        return date
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}


extension ScoreTableViewCell {
    private func setupUI(){
        whiteChessImage.tintColor = ChessColor.white.cgColor
        blackChessImage.tintColor = ChessColor.black.cgColor
    }
    
    func setup(with game: GameHistory){
        dateLabel.text = dateFormatter.string(from: game.date)
        timeLabel.text = game.timeLimit.description()
        boardSize.text = game.boardSize.description()
        
        if let player = game.players.first {
            setupFirstPlayer(with: player)
        }
        
        if let player = game.players.last {
            setupSecondPlayer(with: player)
        }
    }
    
    func setupFirstPlayer(with player: PlayerHistory) {
        playerWhiteLabel.text = player.name
        whiteTimeLabel.text = player.time.secondsToString()
        whiteChessImage.tintColor = player.color.cgColor
        whiteCrownImage.image = player.result.image()
    }
    
    func setupSecondPlayer(with player: PlayerHistory) {
        playerBlackLabel.text = player.name
        blackTimeLabel.text = player.time.secondsToString()
        blackChessImage.tintColor = player.color.cgColor
        blackCrownImage.image = player.result.image()
    }
    
    
    
//    func setup(with scoreItem: ScoreItem){
//        timeLabel.text = scoreItem.time
//        dateLabel.text = scoreItem.date
//        playerWhiteLabel.text = scoreItem.whitePlayerName
//        playerBlackLabel.text = scoreItem.blackPlayerName
//        whiteCrownImage.isHidden = !scoreItem.isWhiteWin
//        blackCrownImage.isHidden = scoreItem.isWhiteWin
//    }
}
