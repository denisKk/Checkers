//
//  PreviewFilmCollectionViewCell.swift
//  Kinopoisk
//
//  Created by Dev on 21.02.22.
//

import UIKit



class
BackgroundGradientCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(with colors: (UIColor, UIColor), check: Bool) {
        if let view = gradientView as? GradientBackgroundView {
            view.startColor = colors.0
            view.endColor = colors.1
        }
        checkmarkImage.isHidden = !check
    }
}
