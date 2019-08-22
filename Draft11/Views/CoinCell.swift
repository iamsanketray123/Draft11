//
//  CoinCell.swift
//  Draft11
//
//  Created by Sanket Ray on 8/16/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit

class CoinCell: UITableViewCell {

    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinName: UILabel!
//    @IBOutlet weak var checked: UIImageView!
    @IBOutlet weak var change24Hours: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    
    var coin: Coin? {
        didSet {
            guard let coin = coin else { return }
            setupUI(coin: coin)
        }
    }
    
    
    fileprivate func setupUI(coin: Coin) {
        coinImage.image = UIImage(named: coin.symbol)
        coinName.text = coin.name
        symbol.text = coin.symbol
        if let change24Hours = coin.percentageChange24h {
            self.change24Hours.text = "\(String(format: "%0.2f", change24Hours))%"
            change24Hours >= 0 ? (self.change24Hours.textColor = UIColor.init(red: 64/255, green: 132/255, blue: 51/255, alpha: 1)): (self.change24Hours.textColor = UIColor.init(red: 1, green: 38/255, blue: 0, alpha: 1))
        }
        
        if let price = coin.price {
            self.currentPrice.text = "₹ \(price.numberToFormattedString(number: price))"
        }
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
extension Double {
    
    func numberToFormattedString(number: Double) -> String {
        
        let truncatedNumber = Double(Int(number*100))/100
        let twoDecimalPlacesNumber = String(format: "%.02f", truncatedNumber)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let formattedNumber = numberFormatter.string(for: Double(twoDecimalPlacesNumber)!) else { return "N/A" }
        
        return formattedNumber
        
    }
    
}
