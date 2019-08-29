//
//  PrizeBreakUpCell.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/19/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class PrizeBreakUpCell: UITableViewCell {

    @IBOutlet weak var rankRange: UILabel!
    @IBOutlet weak var prizeMoney: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
