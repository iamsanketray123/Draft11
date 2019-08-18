//
//  CoinSelectionController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/16/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CoinSelectionController: UIViewController {

    @IBOutlet weak var coinsTable: UITableView!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    var coins = [Coin]()
    var selectedCoins = [Coin]()
    var reference: DatabaseReference!
    let coinCellId = "coinCellId"
    var selectedPool: Pool?
    
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
//                self.animateTopSection()
            }
        }
        
    }
    
    fileprivate func animateTopSection() {
        tableTopConstraint.constant += 80
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmTeamTapped(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let updateValues = generateDictionary(selectedCoins: self.selectedCoins)
        reference.child("Teams").child(uid).child("portfolio").updateChildValues(updateValues)
        
        guard let selectedPool = selectedPool else { return }
        PoolsListController().join(pool: selectedPool, userID: uid)
    }
    
    fileprivate func generateDictionary(selectedCoins: [Coin]) -> [String: Double] {
        
        var dictionary = [String: Double]()
        for coin in selectedCoins {
            dictionary["\(coin.symbol)"] = (20000 / coin.price!)
        }
        
        return dictionary
    }
    
    @IBAction func randomizePlayersAndTeams(_ sender: Any) {
        guard let selectedPool = selectedPool else { return }
        reference.child("Pools").child(selectedPool.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let pool = Pool(dictionary: dictionary)
            let spotsLeft = pool.spotsLeft
            
            for _ in 0..<spotsLeft {
                let randomPlayerUID = NSUUID().uuidString
                var randomPortfolio = [Coin]()
                
                while randomPortfolio.count != 5 {
                    guard let randomCoin = self.coins.randomElement() else { return }
                    if !randomPortfolio.contains(randomCoin) {
                        randomPortfolio.append(randomCoin)
                    } else {
                        print("old coin found")
                    }
                }
                
                let updateValues = self.generateDictionary(selectedCoins: randomPortfolio)
                print("❣️", randomPortfolio, updateValues, "❣️")
                self.reference.child("Teams").child(randomPlayerUID).child("portfolio").updateChildValues(updateValues)
                self.reference.child("Teams").child(randomPlayerUID).child("poolsJoined").updateChildValues([pool.id : Date().timeIntervalSince1970])
            }
            self.reference.child("Pools").child(pool.id).updateChildValues(["spotsLeft" : 0])
        }
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
        if selectedCoins.count < 5 {
            selectedCoins.append(coin)
//            print(selectedCoins)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
//            print(selectedCoins, "max number of coins selected")
            print("max number of coins selected")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.item]
        print("Coin already selected, must remove", coin.symbol)
        guard let indexToRemove = selectedCoins.firstIndex(of: coin) else { return }
        selectedCoins.remove(at: indexToRemove)
//        print(selectedCoins)
        
    }
    
    
}
