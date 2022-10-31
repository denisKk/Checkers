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

final class ScoreTableViewCell: UITableViewCell {

    @IBOutlet private var blackCrownImage: UIImageView!
    @IBOutlet private var blackChessImage: UIImageView!
    @IBOutlet private var playerBlackLabel: UILabel!
    @IBOutlet private var whiteCrownImage: UIImageView!
    @IBOutlet private var whiteChessImage: UIImageView!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var playerWhiteLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var boardSize: UILabel!
    @IBOutlet private var whiteTimeLabel: UILabel!

    @IBOutlet private var blackTimeLabel: UILabel!
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
    private func setupUI() {
        whiteChessImage.tintColor = ChessColor.white.cgColor
        blackChessImage.tintColor = ChessColor.black.cgColor
    }

    func setup(with game: GameHistory) {
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

}
