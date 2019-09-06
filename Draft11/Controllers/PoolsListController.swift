//
//  PoolsListController.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/14/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import GradientLoadingBar

class PoolsListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var comingSoon: UILabel!
    @IBOutlet weak var gradientContainer: UIView!
    
    var reference: DatabaseReference!
    var pools = [Pool]()
    let poolCellId = "poolCellId"
    private var buttonGradientLoadingBar: GradientLoadingBar!
    
    lazy var categoryView: CategoryView = {
        let cv = CategoryView()
        cv.poolsListController = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let gradientColorList = [
            #colorLiteral(red: 0.9577245116, green: 0, blue: 0.2201176882, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.937110126, green: 0.818107307, blue: 0.3834404945, alpha: 1), #colorLiteral(red: 0.5141299367, green: 0.9479157329, blue: 0.1380886734, alpha: 1), #colorLiteral(red: 0, green: 0.9703634381, blue: 0, alpha: 1)
        ]
        
        buttonGradientLoadingBar = GradientLoadingBar(height: 3, gradientColorList: gradientColorList, onView: gradientContainer)
        buttonGradientLoadingBar.show()
        
        categoryContainer.addSubview(categoryView)
        categoryView.anchor(top: categoryContainer.topAnchor, left: categoryContainer.leftAnchor, bottom: categoryContainer.bottomAnchor, right: categoryContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        categoryView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        self.view.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "PoolCell", bundle: nil), forCellWithReuseIdentifier: poolCellId)
        reference = Database.database().reference()
        
        fetchDataAndReload()
        
        reference.child("Pools").observe(.childChanged) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let changedPool = Pool(dictionary: dictionary)
            guard let indexOfPoolToReplace = self.pools.firstIndex(where: {$0.id == changedPool.id}) else { return }
            print("⚠️", changedPool, "⚠️", indexOfPoolToReplace)
            self.pools.remove(at: indexOfPoolToReplace)
            self.pools.insert(changedPool, at: indexOfPoolToReplace)
            self.collectionView.reloadItems(at: [IndexPath(item: indexOfPoolToReplace, section: 0)])
            print(self.pools[indexOfPoolToReplace])
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.isUserInteractionEnabled = true
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        self.navigationController?.pushViewController(ProfileController(), animated: true)
    }
    
    fileprivate func checkIfUserHasCreatedATeam(id: Int) {
        
        collectionView.isUserInteractionEnabled = false
        let pool = pools[id]
        
        if !pool.isContestLive {
            let uid = Auth.auth().currentUser!.uid
            reference.child("Teams").child(uid).observeSingleEvent(of: .value) { (snaphot) in
                let snap = snaphot.value as? [String: Any]
                if snap == nil { // no team has been created
                    let coinSelectionController = CoinSelectionController()
                    coinSelectionController.selectedPool = self.pools[id]
                    DispatchQueue.main.async {
                        self.collectionView.isUserInteractionEnabled = true
                        self.navigationController?.pushViewController(coinSelectionController, animated: true)
                    }
                } else {
                    self.checkIfUserHasJoinedPool(with: id)
                }
            }
        } else {
            print("Pool already live")
            executeContestLiveFlow(pool: pool)
        }
    }
    
    
    fileprivate func executeContestLiveFlow(pool: Pool) {
        print("Game is already live")
        let prizeBreakUpController = PrizeBreakUpController()
        prizeBreakUpController.selectedPool = pool
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(prizeBreakUpController, animated: true)
            return
        }
    }
    
    fileprivate func executeContestIsNotLiveFlow(pool: Pool) {
        print("User has joined this pool but contest isn't live. Start the game.")
        DispatchQueue.main.async {
            let coinSelectionController = CoinSelectionController()
            coinSelectionController.selectedPool = pool
            self.collectionView.isUserInteractionEnabled = true
            self.navigationController?.pushViewController(coinSelectionController, animated: true)
            return
        }
    }
    
    fileprivate func checkIfUserHasJoinedPool(with id: Int) {

        let pool = pools[id]
        if pool.isContestLive {
            executeContestLiveFlow(pool: pool)
            return
        }
        
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
                        } else {
                            self.executeContestLiveFlow(pool: pool)
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
    
    fileprivate func fetchDataAndReload() {
        reference.child("Pools").observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }  
                let pool = Pool(dictionary: dictionary)
                self.pools.append(pool)
            })
            self.pools.sort(by: {$0.totalWinningAmount > $1.totalWinningAmount})
            self.collectionView.reloadData()
            self.buttonGradientLoadingBar.hide()
        }
    }
    
    @objc func handleDisplayPrizeDistribution(_ sender: UIButton) {
        let pool = pools[sender.tag]
        let prizeBreakUpController = PrizeBreakUpController()
        prizeBreakUpController.selectedPool = pool
        self.navigationController?.pushViewController(prizeBreakUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension PoolsListController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        checkIfUserHasCreatedATeam(id: indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: poolCellId, for: indexPath) as! PoolCell
        cell.pool = pools[indexPath.row]
        cell.prizeDistribution.tag = indexPath.item
        cell.prizeDistribution.addTarget(self, action: #selector(handleDisplayPrizeDistribution(_:)), for: .touchUpInside)
        
        if pools[indexPath.item].isContestLive {
            cell.redDot.alpha = 0
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
                cell.redDot.alpha = 1
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.invalidateIntrinsicContentSize()
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            let cell = collectionView.cellForItem(at: indexPath) as! PoolCell
            cell.contentView.backgroundColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1)
            cell.container.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            let cell = collectionView.cellForItem(at: indexPath) as! PoolCell
            cell.contentView.backgroundColor = .clear
            cell.container.transform = .identity
        }
    }
    

}
extension String {
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}


/*
 
 Phase - 1
 It all started in 2016, when I took a leap of faith, to drop out of college and kickstart, "LetsDraft" - a fantasy sports website. Little did I know what I was getting into. After about 9 months of developing the product, with limited funds and no co-founder or a mentor, I took a major hit. The project ended abruptly in its infancy. Having spent all my savings, I had no other option but to take up a job.
 
 Phase - 2
 Joining a startup was the best way to understand how things worked and why I failed. CashRich provided the right platform and Sougata, the required mentorship. I teamed up with Aditya, a finance and strategy MBA graduate from Boston University. We were initially clueless about the idea we wanted to work upon. After months of brainstorming, we decided to revamp my old idea of "Fantasy sports" into "Fantasy Finance". Fantasy sports now was a saturated market and the market for Fantasy finance; well it didn't exist yet! Research provided us 108 million potential customers.
 
 Phase - 3
 This time with a mentor and an experienced co-founder, I am starting my journey. Hope you get onboard ;)
 There are no wrong decisions in life, you have to take a decision and make it right.
 
 */
