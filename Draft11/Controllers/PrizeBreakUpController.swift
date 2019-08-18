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
    
    var selectedPool: Pool?
    let cellId = "cellId"
    let ranks = ["1", "2"]
    let prizes = ["6,500", "3,500"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension PrizeBreakUpController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PrizeBreakUpCell
        cell.rankRange.text = ranks[indexPath.item]
        cell.prizeMoney.text = "₹ \(prizes[indexPath.item])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
