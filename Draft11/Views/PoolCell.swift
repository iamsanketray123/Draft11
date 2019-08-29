//
//  PoolCell.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/14/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase
import GradientProgressBar

class PoolCell: UICollectionViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var confirmedTag: UILabel!
    @IBOutlet weak var entryFee: UILabel!
    @IBOutlet weak var spotsLeft: UILabel!
    @IBOutlet weak var totalSpots: UILabel!
    @IBOutlet weak var percentageOfWinners: UILabel!
    @IBOutlet weak var totalPrizePool: UILabel!
    @IBOutlet weak var progress: GradientProgressBar!
    @IBOutlet weak var prizeDistribution: UIButton!
    @IBOutlet weak var redDot: UIView!
    @IBOutlet weak var entryOrLiveLabel: UILabel!
    
    var pool: Pool? {
        didSet {
            guard let pool = pool else { return }
            setupUI(pool: pool)
        }
    }
    
    fileprivate func setupUI(pool: Pool) {
        
        self.spotsLeft.text = "\(pool.spotsLeft) spots left"
        self.totalSpots.text = "\(pool.totalSpots) spots"
        self.percentageOfWinners.text = "\(pool.percentageOfWinners)% Teams win"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let entryFee = numberFormatter.string(from: pool.entryFee as NSNumber) else { return }
        guard let totalWinningAmount = numberFormatter.string(from: pool.totalWinningAmount as NSNumber) else { return }
        self.totalPrizePool.text = "$ \(totalWinningAmount)"
        self.entryFee.text = "$ \(entryFee)"
        
        
        progress.animationDuration = 1
        progress.gradientColorList = [.orange, UIColor.rgb(200, 40, 30, 0.8)]
        progress.setProgress(0, animated: false)
        progress.setProgress( Float(pool.totalSpots - pool.spotsLeft) / Float(pool.totalSpots), animated: true)
        
        pool.isContestLive ? (redDot.isHidden = false) : (redDot.isHidden = true)
        pool.isContestLive ? (entryOrLiveLabel.text = "Live") : (entryOrLiveLabel.text = "Entry")
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.shadowColor = UIColor.lightGray.cgColor
        container.layer.cornerRadius = 8
        bottomContainer.layer.cornerRadius = 8
        bottomContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        container.layer.shadowOpacity = 3
        container.layer.shadowOffset.width = 0
        container.layer.shadowOffset.height = 3
        container.layer.shadowRadius = 6
        
        confirmedTag.layer.cornerRadius = 1.5
        confirmedTag.layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor
        confirmedTag.layer.borderWidth = 1.25
        
        progress.transform = CGAffineTransform.init(scaleX: 1, y: 1.75)
        progress.layer.cornerRadius = progress.frame.height / 2 * 1.75
        progress.layer.masksToBounds = true
        
    }

}
