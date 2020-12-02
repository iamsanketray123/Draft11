//
//  Coin.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/16/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import Foundation

struct Coin: Equatable {
    let id: Int
    let symbol: String
    let name: String
    let price: Double?
    let percentageChange24h: Double?
    let percentageChange7d: Double?
    
    static func ==(lhs: Coin, rhs: Coin) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.price == rhs.price &&
        lhs.percentageChange24h == rhs.percentageChange24h &&
        lhs.percentageChange7d == rhs.percentageChange7d
    }
}

// MARK: - CoinMarket
struct CoinMarket: Codable {
    let data: [String: CoinCodable]
}

// MARK: - Coin
struct CoinCodable: Codable {
    let id: Int
    let name, symbol, slug: String
    let quote: Quote
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbol, slug
        case quote
    }
}

// MARK: - Quote
struct Quote: Codable {
    let usd: USD
    
    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

// MARK: - USD
struct USD: Codable {
    let price, volume24H, percentChange1H, percentChange24H: Double
    let percentChange7D: Double
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case price
        case volume24H = "volume_24h"
        case percentChange1H = "percent_change_1h"
        case percentChange24H = "percent_change_24h"
        case percentChange7D = "percent_change_7d"
        case lastUpdated = "last_updated"
    }
}


// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
//    public var hashValue: Int {
//        return 0
//    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
