//
//  Pools.swift
//  Draft11
//
//  Created by Sanket Ray on 8/13/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import Foundation


struct Pool {
    let entryFee: Int
    let id: String
    let percentageOfWinners: Int
    let spotsLeft: Int
    let totalSpots: Int
    let totalWinningAmount: Int
    
    init(dictionary: [String: Any]) {
        self.entryFee = dictionary["entryFee"] as? Int ?? Int()
        self.id = dictionary["id"] as? String ?? String()
        self.percentageOfWinners = dictionary["percentageOfWinners"] as? Int ?? Int()
        self.spotsLeft = dictionary["spotsLeft"] as? Int ?? Int()
        self.totalSpots = dictionary["totalSpots"] as? Int ?? Int()
        self.totalWinningAmount = dictionary["totalWinningAmount"] as? Int ?? Int()
    }
}
