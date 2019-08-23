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


let sortedCoinString = "ADA,BCH,BNB,BTC,DASH,EOS,ETC,ETH,LEO,LINK,LTC,MIOTA,NEO,TRX,USDT,XEM,XLM,XMR,XRP,XTZ"

class CoinSelectionController: UIViewController {

    @IBOutlet weak var coinsTable: UITableView!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet var selectedViews: [QuadrilateralView]!
    @IBOutlet weak var selectionCountLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var stack: UIStackView!
    
    
    var spotsLeftForPool = Int()
    var shouldStartGame: Bool?
    var coins = [Coin]()
    var selectedCoins = [Coin]() {
        didSet {
            changeSelectionCountText(count: selectedCoins.count)
            displayConfirmButtonIfRequired()
        }
    }
    var reference: DatabaseReference!
    let coinCellId = "coinCellId"
    var selectedPool: Pool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        reference = Database.database().reference()
        selectedCoins = [Coin]()
        
        coinsTable.delegate = self
        coinsTable.dataSource = self
        coinsTable.allowsMultipleSelection = true
        coinsTable.register(UINib.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: coinCellId)
        
        getCryptoDetailsFor(coinsString: sortedCoinString, currency: "INR", completionForError: { (errorMessage) in
            print(errorMessage)
        }) { (coins) in
            self.coins = coins
            self.coins.sort(by: {$0.symbol < $1.symbol})
            DispatchQueue.main.async {
                self.coinsTable.reloadData()
                if self.shouldStartGame == nil {
                    self.animateTopSection()
                } else {
                    self.confirmButton.setTitle("START", for: .normal)
                    UIView.animate(withDuration: 0.5) {
                        self.confirmButton.alpha = 1
                    }
                }
            }
        }
        
        confirmButton.layer.cornerRadius = 6
        confirmButton.layer.shadowColor = UIColor.lightGray.cgColor
        confirmButton.layer.shadowOpacity = 3
        confirmButton.layer.shadowOffset.width = 0
        confirmButton.layer.shadowOffset.height = 3
        
        
        if let selectedPool = selectedPool {
            reference.child("Pools").child(selectedPool.id).observe(.childChanged) { (snapshot) in
                self.reference.child("Pools").child(selectedPool.id).observe(.value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let pool = Pool(dictionary: dictionary)
                    self.selectedPool = pool
                })
            }
        }
        
        
        
    }
    
    fileprivate func displayConfirmButtonIfRequired() {
        if selectedCoins.count == 5 {
            UIView.animate(withDuration: 0.5) {
                self.confirmButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.confirmButton.alpha = 0
            }
        }
    }
    
    fileprivate func changeSelectionCountText(count: Int) {
        let attributedString = NSMutableAttributedString()
        let selectedCoins = NSAttributedString(string: "\(count)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor(white: 0.8, alpha: 1)])
        let totalCoins = NSAttributedString(string: "/5", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedString.append(selectedCoins)
        attributedString.append(totalCoins)
        selectionCountLabel.attributedText = attributedString
    }
    
    fileprivate func animateTopSection() {
        tableTopConstraint.constant += 80
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.selectionCountLabel.alpha = 1
            self.stack.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmTeamTapped(_ sender: Any) {
        
        if confirmButton.titleLabel?.text == "START" {
            guard let selectedPool = selectedPool else { return }
            reference.child("Pools").child(selectedPool.id).updateChildValues(["isContestLive": true])
            let prizeBreakUpController = PrizeBreakUpController()
            prizeBreakUpController.selectedPool = selectedPool
            self.navigationController?.setViewControllers([PoolsListController(), prizeBreakUpController], animated: true)
            return
        }
        
        if let _ = shouldStartGame {
            print("Current user has already joined the game, but contest is not live. User can now start game")
            displayAlertForRandomization()
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let selectedPool = selectedPool else { return }
            
            if !selectedPool.playerUIDs.contains(uid) { // if player has not joined the pool
                let updateValues = generateDictionary(selectedCoins: self.selectedCoins)
                reference.child("Teams").child(uid).child("portfolio").updateChildValues(updateValues)
                join(pool: selectedPool, userID: uid)
            }
            
            displayAlertForRandomization()
        }
        
        
        
    }
    
    func join(pool: Pool, userID: String) {
        print(pool, "☢️")
        reference = Database.database().reference()
        reference.child("Pools").child(pool.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary  = snapshot.value as? [String: Any] else { return }
            print(dictionary, "🚦")
            let pool = Pool(dictionary: dictionary)
            if pool.spotsLeft >= 1 {
                self.reference.child("Pools").child(pool.id).updateChildValues(["spotsLeft" : (pool.spotsLeft - 1)])
                self.reference.child("Pools").child(pool.id).child("players").updateChildValues([userID: Date().timeIntervalSince1970])
                self.handleDeselectionAndStartGame()
            } else {
                print("Pool already filled, sorry!")
            }
        }
    }

    fileprivate func handleDeselectionAndStartGame() {
        guard let indexPathsForSelectedRows = self.coinsTable.indexPathsForSelectedRows else { return }
        indexPathsForSelectedRows.forEach({self.coinsTable.deselectRow(at: $0, animated: false)})
        confirmButton.setTitle("START", for: .normal)
        selectedViews.forEach({$0.isSelected = false})
    }
    
    
    fileprivate func displayAlertForRandomization() {
        
        let alert = UIAlertController(title: "Successfully Joined Contest", message: "The total number of slots for this contest have not been filled. Click on 'Randomize' to play against AI bots or wait for others to join", preferredStyle: .alert)
        let randomizeAction = UIAlertAction(title: "Play against AI", style: .default) { (_) in
            self.randomizePlayersAndTeams()
        }
        let cancelAction = UIAlertAction(title: "Wait for other Players", style: .destructive)
        alert.addAction(randomizeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    fileprivate func generateDictionary(selectedCoins: [Coin]) -> [String: Double] {
        
        var dictionary = [String: Double]()
        for coin in selectedCoins {
            dictionary["\(coin.symbol)"] = (20000 / coin.price!)
        }
        
        return dictionary
    }
    
    fileprivate func randomizePlayersAndTeams() {
        guard let selectedPool = selectedPool else { return }
        reference.child("Pools").child(selectedPool.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let pool = Pool(dictionary: dictionary)
            let spotsLeft = pool.spotsLeft
            self.spotsLeftForPool = spotsLeft
            
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
                self.reference.child("Pools").child(pool.id).child("players").updateChildValues([randomPlayerUID: Date().timeIntervalSince1970])
                
                self.spotsLeftForPool -= 1
                self.reference.child("Pools").child(pool.id).updateChildValues(["spotsLeft" : self.spotsLeftForPool])
                
                if let randomName = randomNames.randomElement() {
                    self.reference.child("Users").child(randomPlayerUID).updateChildValues(["userName": randomName])
                }
            }
            self.reference.child("Pools").child(pool.id).updateChildValues(["isContestLive": true])
            
            DispatchQueue.main.async {
                let prizeBreakUpController = PrizeBreakUpController()
                prizeBreakUpController.selectedPool = selectedPool
                self.navigationController?.setViewControllers([PoolsListController(), prizeBreakUpController], animated: true)
            }
            
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
       
        
        for view in selectedViews {
            if !view.isSelected {
                view.isSelected = true
                view.setNeedsDisplay()
                break
            }
        }
        
        
        if selectedCoins.count < 5 {
            selectedCoins.append(coin)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            print("max number of coins selected")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        for view in selectedViews.reversed() {
            if view.isSelected {
                view.isSelected = false
                view.setNeedsDisplay()
                break
            }
        }
        
        let coin = coins[indexPath.item]
        print("Coin already selected, must remove", coin.symbol)
        guard let indexToRemove = selectedCoins.firstIndex(of: coin) else { return }
        selectedCoins.remove(at: indexToRemove)
    }
    
    
}

