//
//  DesignButton.swift
//  Checkers(kulakov)
//
//  Created by Dev on 8.02.22.
//

import UIKit

@IBDesignable
class BorderButton: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!

    @IBInspectable var isEnabled: Bool {
        get {return isEnabled_}
        set {isEnabled_ = newValue}
    }

    private var isEnabled_: Bool = true {
        didSet {setupColor()}
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    @IBInspectable var caption: String {
        get {return captionLabel.text ?? ""}
        set {captionLabel.text = newValue.localized}
    }

    @IBInspectable var image: UIImage? {
        get {return imageView.image}
        set {imageView.image = newValue}
    }

    private var color_: UIColor = .clear {
        didSet {setupColor()}
    }

    @IBInspectable var color: UIColor {
        get { return color_}
        set {color_ = newValue}
    }

    private func setupUI() {
        Bundle(for: BorderButton.self).loadNibNamed("BorderButton", owner: self, options: nil)
        contentView.frame = bounds
        contentView.backgroundColor = UIColor.clear
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        captionLabel.text = ""
        self.addSubview(contentView)
    }

    func setupColor() {
        if isEnabled {
            contentView.layer.borderColor = color_.cgColor
            captionLabel.textColor = color_
            imageView.tintColor = color_
        } else {
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            captionLabel.textColor = .lightGray
            imageView.tintColor = .lightGray
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else {return}
        contentView.backgroundColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9607843137, alpha: 0.2629087334)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.backgroundColor = UIColor.clear
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        contentView.backgroundColor = UIColor.clear
    }
}
