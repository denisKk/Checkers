//
//  UIView.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit

extension UIView {

    static let tagConstant = 110101

    func showLoading() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = UIView.tagConstant

        let activityIndicator = UIActivityIndicatorView(style: .large)

        blurEffectView.alpha = 0
        addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.center
        activityIndicator.startAnimating()

        UIView.animate(withDuration: 0.1) {
            blurEffectView.alpha = 1.0
        }
    }

    func closeLoading() {
        let blur = subviews.first(where: { $0.tag == UIView.tagConstant })

        UIView.animate(withDuration: 0.1) {
            blur?.alpha = 0
        } completion: { _ in
            (blur?.subviews.first(where: {
                ($0 as? UIActivityIndicatorView) != nil
            }) as? UIActivityIndicatorView)?.stopAnimating()

            blur?.removeFromSuperview()
        }
    }

}
