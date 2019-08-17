//
//  CoinSelectionController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/16/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import FirebaseDatabase


class CoinSelectionController: UIViewController {

    @IBOutlet weak var coinsTable: UITableView!
    
    var coins = [Coin]()
    var selectedCoins = [Coin]()
    var reference: DatabaseReference!
    let coinCellId = "coinCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reference = Database.database().reference()
        
        coinsTable.delegate = self
        coinsTable.dataSource = self
        coinsTable.allowsMultipleSelection = true
        coinsTable.register(UINib.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: coinCellId)
        
        let coinsString = "BTC,ETH,XRP,BCH,LTC,BNB,USDT,EOS,XMR,XLM,LEO,ADA,TRX,DASH,LINK,XTZ,NEO,MIOTA,ETC,XEM"
        var coinsArray = coinsString.split(separator: ",")
        coinsArray.sort(by: {$0 < $1})
        let sortedCoinsString = coinsArray.joined(separator: ",")

        getCryptoDetailsFor(coinsString: sortedCoinsString, currency: "INR", completionForError: { (errorMessage) in
            print(errorMessage)
        }) { (coins) in
            self.coins = coins
            self.coins.sort(by: {$0.symbol < $1.symbol})
            DispatchQueue.main.async {
                self.coinsTable.reloadData()
            }
        }
        
    }
    
    
//    fileprivate func fetchCoinsFromFirebase() {
//        reference.child("Coins").observeSingleEvent(of: .value) { (snapshot) in
//            guard let dictionary = snapshot.value as? [String: Any] else { return }
//
//            dictionary.forEach({ (key, value) in
//                let coin = Coin(symbol: key as String, name: value as! String, price: nil, percentageChange24h: nil, percentageChange7d: nil)
//                self.coins.append(coin)
//            })
//            DispatchQueue.main.async {
//                self.coins.sort(by: {$0.name < $1.name})
//                self.coinsTable.reloadData()
//            }
//
//        }
//    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}


extension CoinSelectionController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: coinCellId, for: indexPath) as! CoinCell
        cell.coin = coins[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.item]
        print(coin.symbol)
        if selectedCoins.count <= 5 {
            selectedCoins.append(coin)
            print(selectedCoins)
        } else {
            print(selectedCoins, "max number of coins selected")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.item]
        print("Coin already selected, must remove", coin.symbol)
        guard let indexToRemove = selectedCoins.firstIndex(of: coin) else { return }
        selectedCoins.remove(at: indexToRemove)
        print(selectedCoins)
        
    }
    
    
}
