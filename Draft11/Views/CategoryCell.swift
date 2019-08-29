//
//  CategoryCell.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/18/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    let label : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    let redView : UIView = {
        let redView = UIView()
        redView.backgroundColor = UIColor.rgb(200, 40, 30)
        return redView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        contentMode = .center
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(redView)
        redView.alpha = 0
        redView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 2)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                label.textColor = UIColor.draft11Red()
                UIView.animate(withDuration: 0.5) {
                    self.redView.alpha = 1
                }
            } else {
                label.textColor = .lightGray
                redView.alpha = 0
            }
        }
    }
}











