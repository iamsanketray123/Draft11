//
//  Extensions.swift
//  Fanrex
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
    static func draft11Red() -> UIColor {
        return UIColor(red: 200/255, green: 40/255, blue: 30/255, alpha: 1)
    }
}


class QuadrilateralView : UIView {
    
    var path: UIBezierPath!
    var isSelected = Bool()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        drawQuadrilateral(color: .white)
    }
    
    func drawQuadrilateral(color: UIColor) {
        
        path = UIBezierPath()
        let a = CGPoint(x: self.frame.width / 5, y: 0)
        let b = CGPoint(x: 0, y: self.frame.width / 2.5)
        let c = CGPoint(x: self.frame.width * 0.8, y: self.frame.width / 2.5)
        let d = CGPoint(x: self.frame.width, y: 0)
        
        path.move(to: a)
        path.addLine(to: b)
        path.addLine(to: c)
        path.addLine(to: d)
        path.close()
        
        if isSelected {
            UIColor.rgb(4, 159, 54).setFill()
        } else {
            color.setFill()
        }
        
        path.fill()
    }
}


@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
extension String {
    
    var isValidName: Bool {
        let RegEx = "^[\\p{L} .'-]+$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: self)
    }
}

class Alert {
    class func showBasic(title : String , message: String, vc : UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
}
