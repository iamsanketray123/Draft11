//
//  SettingsCell.swift
//  Draft11
//
//  Created by Sanket Ray on 8/25/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var option: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
