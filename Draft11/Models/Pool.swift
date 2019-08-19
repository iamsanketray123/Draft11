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
    var winnerRanges = [[Int]]()
    var prizeRanges = [Int]()
    
    init(dictionary: [String: Any]) {
        self.entryFee = dictionary["entryFee"] as? Int ?? Int()
        self.id = dictionary["id"] as? String ?? String()
        self.percentageOfWinners = dictionary["percentageOfWinners"] as? Int ?? Int()
        self.spotsLeft = dictionary["spotsLeft"] as? Int ?? Int()
        self.totalSpots = dictionary["totalSpots"] as? Int ?? Int()
        self.totalWinningAmount = dictionary["totalWinningAmount"] as? Int ?? Int()
        
        let prizeBreakupStrings = dictionary["prizeBreakup"] as? [String: Int] ?? [String: Int]()
        setupPrizeRange(prizeBreakupStrings: prizeBreakupStrings)
    }
    
    mutating func setupPrizeRange(prizeBreakupStrings: [String: Int]) {

        for (key,value) in prizeBreakupStrings {
            let a = key.replacingOccurrences(of: "\"", with: String())
            
            if a.contains("-") {
                
                let b = a.split(separator: "-")
                let lowerBound = Int(b[0])!
                let upperBound = Int(b[1])!
                self.winnerRanges.append([Int](lowerBound...upperBound))
                
            } else {
                self.winnerRanges.append([Int(a)!])
            }
            
            self.prizeRanges.append(value)
        }
    }
}
