//
//  CryptoDetails.swift
//  Draft11
//
//  Created by Sanket Ray on 8/16/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import Foundation

func getCryptoDetailsFor(coinsString: String, currency: String, completionForError: @escaping(_ errorMessage: String)->Void, completionForCoins: @escaping(_ response: [Coin])-> Void) {
    
    var coins = [Coin]()

    guard let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=\(coinsString)&convert=\(currency)") else { return }
    
    var request = URLRequest(url: url)
    
    request.httpMethod = "GET"
    
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 20
    config.timeoutIntervalForResource = 20
    request.addValue("29366e8f-d165-48fb-94c2-e36c5b79d456", forHTTPHeaderField: "X-CMC_PRO_API_KEY")
    
    let session = URLSession(configuration: config)
    
    session.dataTask(with: request) { (data, response, error) in
        
        guard error == nil else{
            print("error while requesting data")
            completionForError("Sorry, something went wrong. Please try again.")
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            print("status code was other than 2xx", (response as! HTTPURLResponse).statusCode,"🍅")
            completionForError("Sorry, something went wrong. Please try again.")
            return
        }
        guard let data = data else {
            print("request for data failed")
            completionForError("Sorry, something went wrong. Please try again.")
            return
        }
        
        let coinMarket = try? JSONDecoder().decode(CoinMarket.self, from: data)
        
        
        guard let responses = coinMarket?.data else { return }
        
        for response in responses {

            let coinCodable = response.value
            let coin = Coin(id: coinCodable.id, symbol: coinCodable.symbol, name: coinCodable.name, price: coinCodable.quote.inr.price, percentageChange24h: coinCodable.quote.inr.percentChange24H, percentageChange7d: coinCodable.quote.inr.percentChange7D)
            coins.append(coin)
        }
        
        completionForCoins(coins)
        
        
    }.resume()
    
    
}
