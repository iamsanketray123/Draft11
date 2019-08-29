//
//  PrizeBreakUpController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/19/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import GradientProgressBar
import FirebaseDatabase
import FirebaseAuth
import GradientLoadingBar

class PrizeBreakUpController: UIViewController {
    
    @IBOutlet weak var progress: GradientProgressBar!
    @IBOutlet weak var spotsLeft: UILabel!
    @IBOutlet weak var totalSpots: UILabel!
    @IBOutlet weak var percentageOfWinners: UILabel!
    @IBOutlet weak var confirmedTag: UILabel!
    @IBOutlet weak var totalPrizePool: UILabel!
    @IBOutlet weak var entryFee: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var prizeBreakupContainer: UIView!
    @IBOutlet weak var trophyContainer: UIView!
    @IBOutlet weak var entryOrLiveLabel: UILabel!
    @IBOutlet weak var redDot: UIView!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var gradientContainer: UIView!
    @IBOutlet weak var endGameButton: UIButton!
    @IBOutlet weak var waitingLabel: UILabel!
    
    var selectedPool: Pool?
    let cellId = "cellId"
    let leaderBoardCellId = "leaderBoardCellId"
    var reference: DatabaseReference!
    private var buttonGradientLoadingBar: GradientLoadingBar!
    var rankStringRange = [String]()
    var amounts = [String]()
    
    
    var portfolioValues = [PortfolioValue]() {
        didSet {
            guard let selectedPool = selectedPool else { return }
            if portfolioValues.count == selectedPool.totalSpots {
                portfolioValues.sort(by: {$0.value > $1.value})
                DispatchQueue.main.async {
                    self.buttonGradientLoadingBar.hide()
                    self.leaderboardTable.reloadData()
                }
            }
        }
    }
    
    lazy var prizeBreakupView: PrizeBreakupAndLearboardView = {
        let pbv = PrizeBreakupAndLearboardView()
        pbv.prizeBreakUpController = self
        return pbv
    }()
    
    
    fileprivate func fetchPoolDetails(selectedPool: Pool) {
        reference.child("Pools").child(selectedPool.id).observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let pool = Pool(dictionary: dictionary)
            self.selectedPool = pool
            self.setupCell()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientColorList = [
            #colorLiteral(red: 0.9577245116, green: 0, blue: 0.2201176882, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.937110126, green: 0.818107307, blue: 0.3834404945, alpha: 1), #colorLiteral(red: 0.5141299367, green: 0.9479157329, blue: 0.1380886734, alpha: 1), #colorLiteral(red: 0, green: 0.9703634381, blue: 0, alpha: 1)
        ]
        
        buttonGradientLoadingBar = GradientLoadingBar(height: 3, gradientColorList: gradientColorList, onView: gradientContainer)
        
        reference = Database.database().reference()
        
        createRankStringRange()
        sortPrizeRange()
        setupUI()
        
        if let selectedPool = selectedPool {
            
            fetchPoolDetails(selectedPool: selectedPool)
            
            reference.child("Pools").child(selectedPool.id).observe(.childChanged) { (snapshot) in
                self.fetchPoolDetails(selectedPool: selectedPool)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateRedDot()
        
    }
    
    @IBAction func checkIfUserHasCreatedATeam(_ sender: Any) {
        guard let pool = selectedPool else { return }
        if !pool.isContestLive {
            let uid = Auth.auth().currentUser!.uid
            reference.child("Teams").child(uid).observeSingleEvent(of: .value) { (snaphot) in
                let snap = snaphot.value as? [String: Any]
                if snap == nil { // no team has been created
                    let coinSelectionController = CoinSelectionController()
                    coinSelectionController.selectedPool = self.selectedPool
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(coinSelectionController, animated: true)
                    }
                } else {
                    self.checkIfUserHasJoinedPool()
                }
            }
        } else {
            print("Contest is alrady live")
        }
    }
    
    fileprivate func checkIfUserHasJoinedPool() {
        
        guard let pool = selectedPool else { return }

        guard let userID = Auth.auth().currentUser?.uid else { return }
        reference.child("Pools").child(pool.id).child("players").observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as? [String: Any]
            
            if snap == nil {
                self.join(pool: pool, userID: userID)
            } else {
                guard let snap = snap else { return }
                var hasLoggedInUserJoined = false
                for (key, _) in snap {
                    if key == userID {
                        print("Already join this pool")
                        
                        hasLoggedInUserJoined = true
                        
                        if !pool.isContestLive {
                            self.executeContestIsNotLiveFlow(pool: pool)
                        }
                    }
                }
                if !hasLoggedInUserJoined {
                    print("User has not joined this pool")
                    self.join(pool: pool, userID: userID)
                }
            }
        }
    }
    
    fileprivate func executeContestIsNotLiveFlow(pool: Pool) {
        print("User has joined this pool but contest isn't live. Start the game.")
        DispatchQueue.main.async {
            let coinSelectionController = CoinSelectionController()
            coinSelectionController.selectedPool = pool
            self.navigationController?.pushViewController(coinSelectionController, animated: true)
            return
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
            } else {
                print("Pool already filled, sorry!")
            }
        }
    }
    
    @IBAction func endGameTapped(_ sender: Any) {
        let revenueController = RevenueController()
        revenueController.pool = selectedPool
        self.navigationController?.pushViewController(revenueController, animated: true)
    }
    
    fileprivate func setupUI() {
        
        prizeBreakupContainer.addSubview(prizeBreakupView)
        prizeBreakupView.anchor(top: prizeBreakupContainer.topAnchor, left: prizeBreakupContainer.leftAnchor, bottom: prizeBreakupContainer.bottomAnchor, right: prizeBreakupContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        prizeBreakupView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        confirmedTag.layer.cornerRadius = 1.5
        confirmedTag.layer.borderColor = UIColor(white: 0, alpha: 0.25).cgColor
        confirmedTag.layer.borderWidth = 1.25
        
        table.delegate = self
        table.dataSource = self
        table.register(UINib.init(nibName: "PrizeBreakUpCell", bundle: nil), forCellReuseIdentifier: cellId)
        table.tableFooterView = UIView()
        
        leaderboardTable.delegate = self
        leaderboardTable.dataSource = self
        leaderboardTable.register(UINib.init(nibName: "PortfolioValueCell", bundle: nil), forCellReuseIdentifier: leaderBoardCellId)
        leaderboardTable.tableFooterView = UIView()
        
        
        let grayLine = UIView()
        grayLine.backgroundColor = UIColor.rgb(200, 200, 200)
        prizeBreakupContainer.addSubview(grayLine)
        grayLine.anchor(top: prizeBreakupContainer.topAnchor, left: prizeBreakupContainer.leftAnchor, bottom: nil, right: prizeBreakupContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        prizeBreakupContainer.layer.shadowColor = UIColor.lightGray.cgColor
        prizeBreakupContainer.layer.shadowOpacity = 3
        prizeBreakupContainer.layer.shadowOffset.width = 0
        prizeBreakupContainer.layer.shadowOffset.height = 3
        
    }
    
    
    fileprivate func animateRedDot() {
        self.redDot.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.redDot.alpha = 1
        })
    }
    
    fileprivate func setupCell() {
        
        if let pool = selectedPool {
            pool.isContestLive ? (endGameButton.isHidden = false) : (endGameButton.isHidden = true)
        }
        
        progress.transform = CGAffineTransform.init(scaleX: 1, y: 1.75)
        progress.layer.cornerRadius = progress.frame.height
        progress.layer.masksToBounds = true
        
        guard let pool = selectedPool else { return }
        
        self.spotsLeft.text = "\(pool.spotsLeft) spots left"
        self.totalSpots.text = "\(pool.totalSpots) spots"
        self.percentageOfWinners.text = "\(pool.percentageOfWinners)%"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let entryFee = numberFormatter.string(from: pool.entryFee as NSNumber) else { return }
        guard let totalWinningAmount = numberFormatter.string(from: pool.totalWinningAmount as NSNumber) else { return }
        self.totalPrizePool.text = "$ \(totalWinningAmount)"
        self.entryFee.text = "$ \(entryFee)"
        
        
        progress.animationDuration = 1
        progress.gradientColorList = [.orange, UIColor.rgb(200, 40, 30, 0.8)]
        progress.setProgress(0, animated: false)
        progress.setProgress( Float(pool.totalSpots - pool.spotsLeft) / Float(pool.totalSpots), animated: true)
        
        if pool.isContestLive {
            entryOrLiveLabel.text = "Live"
            redDot.isHidden = false
        } else {
            entryOrLiveLabel.text = "Entry"
            redDot.isHidden = true
        }
    }
    
    func displayTrophyIfRequired() {
        if rankStringRange.count == 1 && rankStringRange.first?.count == 1 {
            trophyContainer.alpha = 1
            table.isHidden = true
        } else {
            trophyContainer.alpha = 0
            table.isHidden = false
        }
    }
    
    fileprivate func sortPrizeRange() {
        if let selectedPool = selectedPool {
            let sortedAmounts = selectedPool.prizeRanges.sorted(by: {$0 > $1})
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            amounts = sortedAmounts.map({formatter.string(from: NSNumber(value: $0))!})
            displayTrophyIfRequired()
        }
        
    }
    
    fileprivate func createRankStringRange() {
        if let selectedPool = selectedPool {
            let sortedWinnersRange = selectedPool.winnerRanges.sorted(by: { $0[0] < $1[0] })
            
            for range in sortedWinnersRange {
                if range.count == 1 {
                    rankStringRange.append("\(range[0])")
                } else {
                    rankStringRange.append("\(range[0]) - \(range[range.count - 1])")
                }
            }
            
            print(rankStringRange)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getPlayers() {
        buttonGradientLoadingBar.show()
        portfolioValues = [PortfolioValue]() // remove everything before
        DispatchQueue.main.async {
            self.leaderboardTable.reloadData()
        }
        
        guard let pool = selectedPool else { return }
        let playerIDs = pool.playerUIDs
        print(playerIDs, "🆔")
        if pool.isContestLive {
            waitingLabel.alpha = 0
            getCryptoDetailsFor(coinsString: sortedCoinString, currency: "USD", completionForError: { (errorMessage) in
                print(errorMessage)
            }) { (coinsFromAPICall) in
                
                for playerID in playerIDs {
                    self.reference.child("Teams").child(playerID).child("portfolio").observeSingleEvent(of: .value, with: { (snap) in
                        guard let allCoinsArray = snap.value as? [String: Any] else { return }
                        let allCoinsForUser = self.generateCoinsAndUnits(allCoinsArray: allCoinsArray)
                        
                        var totalValueOfUser = Double()
                        
                        for i in coinsFromAPICall {
                            for j in allCoinsForUser {
                                if i.symbol == j.symbol {
                                    guard let price = i.price else { return }
                                    totalValueOfUser += price * j.unitsPurchased
                                }
                            }
                        }
                        self.getNameOfUserFrom(uid: playerID, value: totalValueOfUser)
                    })
                }
            }
        } else {
            buttonGradientLoadingBar.hide()
            UIView.animate(withDuration: 1) {
                self.waitingLabel.alpha = 1
            }
            print("Waiting for other players to join")
        }
    }
    
    func getNameOfUserFrom(uid: String, value: Double) {
        
        reference.child("Users").child(uid).observe(.value) { (snapshot) in
            guard let snap = snapshot.value as? [String: String] else { return }
            if let userName = snap["userName"] {
                print("✅✅", uid, userName, "✅✅", value)
                let portfolioValue = PortfolioValue(nameOfPlayer: userName, value: value)
                self.portfolioValues.append(portfolioValue)
            }
        }
    }
    
    
    
    func generateCoinsAndUnits(allCoinsArray: [String: Any])-> [PortfolioCoin] {
        var allCoins = [PortfolioCoin]()
        for coin in allCoinsArray {
            allCoins.append(PortfolioCoin(symbol: coin.key, unitsPurchased: coin.value as! Double))
        }
        return allCoins
    }
    
}

extension PrizeBreakUpController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.table {
            return rankStringRange.count
        } else { // leaderboard table
            return portfolioValues.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.table {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PrizeBreakUpCell
            cell.rankRange.text = rankStringRange[indexPath.item]
            cell.prizeMoney.text = "$ \(amounts[indexPath.item])"
            return cell
        } else { // leaderboard table
            let cell = tableView.dequeueReusableCell(withIdentifier: leaderBoardCellId, for: indexPath) as! PortfolioValueCell
            cell.portfolio = portfolioValues[indexPath.row]
            cell.rank.text = "\(indexPath.row + 1)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
