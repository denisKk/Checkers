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
    
    func setup(with scoreItem: ScoreItem){
        timeLabel.text = scoreItem.time
        dateLabel.text = scoreItem.date
        playerWhiteLabel.text = scoreItem.whitePlayerName
        playerBlackLabel.text = scoreItem.blackPlayerName
        whiteCrownImage.isHidden = !scoreItem.isWhiteWin
        blackCrownImage.isHidden = scoreItem.isWhiteWin
    }
}
