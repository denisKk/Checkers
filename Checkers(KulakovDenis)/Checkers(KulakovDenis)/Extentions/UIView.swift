//
//  UIView.swift
//  Checkers(kulakov)
//
//  Created by Dev on 30.01.22.
//

import UIKit

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.3, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func hideAnimation(){
        UIView.animate(withDuration: 0.7) {
            self.alpha = 0
        }
    }
    
    func showAnimation(){
        self.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func showLoading() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 110101
        
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
        let blur = subviews.first(where: { $0.tag == 110101 })
        
        UIView.animate(withDuration: 0.1) {
            blur?.alpha = 0
        } completion: { _ in
            (blur?.subviews.first(where: { ($0 as? UIActivityIndicatorView) != nil}) as? UIActivityIndicatorView)?.stopAnimating()
                
            blur?.removeFromSuperview()
        }
    }
   
}
