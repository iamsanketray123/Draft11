//
//  Extensions.swift
//  Draft11
//
//  Created by Sanket Ray on 8/18/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

extension UIView {
    func anchor(top : NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop : CGFloat, paddingLeft : CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width : CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func shake(view: UIView, for duration: TimeInterval = 1, withTranslation translation: CGFloat = 10) {
        
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.45) {
            view.layer.borderColor = UIColor.red.cgColor
            view.layer.borderWidth = 1.5
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
            view.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        
        propertyAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.addCompletion { (_) in
            view.layer.borderWidth = 0
        }
        
        
        propertyAnimator.startAnimation()
        
    }
    
}

extension UIColor {
    static func rgb(_ red : CGFloat,_ green: CGFloat,_ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    static func placeHolder() -> UIColor {
        return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    }
    static func cashRichGreen() -> UIColor {
        return UIColor(red: 0/255, green: 176/255, blue: 130/255, alpha: 1)
    }
}
