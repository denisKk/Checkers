//
//  LanguageCollectionViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 29.06.22.
//

import UIKit

final class LanguageCollectionViewCell: UICollectionViewCell {

    @IBOutlet var backView: UIView!
    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 4
        backView.layer.borderColor = UIColor.green.cgColor
    }

    func setup(with title:String, bordered: Bool){
        titleLabel.text = title.uppercased()
        backView.layer.borderWidth = bordered ? 2 : 0
    }
    
    
}
