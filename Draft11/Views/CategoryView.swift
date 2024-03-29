//
//  CategoryView.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/18/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class CategoryView: UIView {
    
    let cellId = "cellId"
    let categories = ["CRYPTOS", "STOCKS", "INDICES"]
    var poolsListController : PoolsListController?
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = true
        cv.alwaysBounceHorizontal = true
        cv.backgroundColor = .clear
        cv.isUserInteractionEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(collectionView)
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CategoryView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        
        cell.label.text = categories[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3.4, height: frame.height - 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let poolsListController = poolsListController {
            if indexPath.item == 0 {
                poolsListController.collectionView.isHidden = false
                poolsListController.comingSoon.alpha = 0
            } else {
                poolsListController.collectionView.isHidden = true
                poolsListController.comingSoon.alpha = 0
                UIView.animate(withDuration: 1) {
                    poolsListController.comingSoon.alpha = 1
                }
            }
        }
    }
}
