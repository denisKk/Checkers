//
//  LanguageCollectionViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 29.06.22.
//

import UIKit

class LanguageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.cornerRadius = 4
        backView.layer.borderColor = UIColor.green.cgColor
    }

    func setup(with title:String, bordered: Bool){
        titleLabel.text = title.uppercased()
        backView.layer.borderWidth = bordered ? 2 : 0
    }
    
    
}
