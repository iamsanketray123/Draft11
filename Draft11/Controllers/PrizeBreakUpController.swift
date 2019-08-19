//
//  PrizeBreakUpController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/19/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import GradientProgressBar

class PrizeBreakUpController: UIViewController {

    @IBOutlet weak var progress: GradientProgressBar!
    @IBOutlet weak var spotsLeft: UILabel!
    @IBOutlet weak var totalSpots: UILabel!
    @IBOutlet weak var percentageOfWinners: UILabel!
    @IBOutlet weak var confirmedTag: UILabel!
    @IBOutlet weak var totalPrizePool: UILabel!
    @IBOutlet weak var entryFee: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var prizeBreakupContainer: UIView!
    @IBOutlet weak var trophyContainer: UIView!
    
    var selectedPool: Pool?
    let cellId = "cellId"

    var rankStringRange = [String]()
    var amounts = [String]()
    
    lazy var prizeBreakupView: PrizeBreakupAndLearboardView = {
        let pbv = PrizeBreakupAndLearboardView()
        pbv.prizeBreakUpController = self
        return pbv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createRankStringRange()
        sortPrizeRange()

        prizeBreakupContainer.addSubview(prizeBreakupView)
        prizeBreakupView.anchor(top: prizeBreakupContainer.topAnchor, left: prizeBreakupContainer.leftAnchor, bottom: prizeBreakupContainer.bottomAnchor, right: prizeBreakupContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        prizeBreakupView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        
        guard let pool = selectedPool else { return }
        
        self.spotsLeft.text = "\(pool.spotsLeft) spots left"
        self.totalSpots.text = "\(pool.totalSpots) spots"
        self.percentageOfWinners.text = "\(pool.percentageOfWinners)%"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let entryFee = numberFormatter.string(from: pool.entryFee as NSNumber) else { return }
        guard let totalWinningAmount = numberFormatter.string(from: pool.totalWinningAmount as NSNumber) else { return }
        self.totalPrizePool.text = "₹ \(totalWinningAmount)"
        self.entryFee.text = "₹ \(entryFee)"
        
        
        progress.animationDuration = 1
        progress.gradientColorList = [.orange, UIColor.rgb(200, 40, 30, 0.8)]
        progress.setProgress(0, animated: false)
        progress.setProgress( Float(pool.totalSpots - pool.spotsLeft) / Float(pool.totalSpots), animated: true)
        
        confirmedTag.layer.cornerRadius = 1.5
        confirmedTag.layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor
        confirmedTag.layer.borderWidth = 1.25
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib.init(nibName: "PrizeBreakUpCell", bundle: nil), forCellReuseIdentifier: cellId)
        table.tableFooterView = UIView()
    }
    
    fileprivate func sortPrizeRange() {
        if let selectedPool = selectedPool {
            let sortedAmounts = selectedPool.prizeRanges.sorted(by: {$0 > $1})
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            amounts = sortedAmounts.map({formatter.string(from: NSNumber(value: $0))!})
            
            if rankStringRange.count == 1 && rankStringRange.first?.count == 1 {
                trophyContainer.alpha = 1
                table.isHidden = true
            } else {
                trophyContainer.alpha = 0
                table.isHidden = false
            }
        }
        
    }
    
    fileprivate func createRankStringRange() {
        if let selectedPool = selectedPool {
            let sortedWinnersRange = selectedPool.winnerRanges.sorted(by: { $0[0] < $1[0] })
            
            for range in sortedWinnersRange {
                if range.count == 1 {
                    rankStringRange.append("\(range[0])")
                } else {
                    rankStringRange.append("\(range[0]) - \(range[range.count - 1])")
                }
            }
            
            print(rankStringRange)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension PrizeBreakUpController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankStringRange.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PrizeBreakUpCell
        cell.rankRange.text = rankStringRange[indexPath.item]
        cell.prizeMoney.text = "₹ \(amounts[indexPath.item])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
