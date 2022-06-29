//
//  LanguageCollectionViewCell.swift
//  Checkers(KulakovDenis)
//
//  Created by Dev on 29.06.22.
//

import UIKit

class LanguageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(with title:String){
        titleLabel.text = title.uppercased()
    }
}
