//
//  PortfolioValueCell.swift
//  Draft11
//
//  Created by Sanket Ray on 8/22/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class PortfolioValueCell: UITableViewCell {
    
    
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var portfolioValue: UILabel!
    
    var portfolio: PortfolioValue? {
        didSet {
            guard let portfolio = portfolio else { return }
            setupUI(portfolio: portfolio)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(portfolio: PortfolioValue) {
        self.name.text = "\(portfolio.nameOfPlayer)"
        self.portfolioValue.text = "\(portfolio.value.numberToFormattedString(number: portfolio.value))"
    }
    
}
