//
//  PoolsListController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/14/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class PoolsListController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var reference: DatabaseReference!
    var pools = [Pool]()
    let poolCellId = "poolCellId"
    
    let a = [String:String]()
    //    let pools = [
    //        Pool(entryFee: 5750, id: 1, percentageOfWinners: 50, spotsLeft: 2, totalSpots: 2, totalWinningAmount: 10000),
    //        Pool(entryFee: 2000, id: 2, percentageOfWinners: 33, spotsLeft: 6, totalSpots: 6, totalWinningAmount: 10000),
    //        Pool(entryFee: 60, id: 3, percentageOfWinners: 50, spotsLeft: 10, totalSpots: 10, totalWinningAmount: 500),
    //        Pool(entryFee: 165, id: 4, percentageOfWinners: 82, spotsLeft: 11, totalSpots: 11, totalWinningAmount: 1500)
    //    ]
    
    //    fileprivate func addPools() {
    //        for pool in pools {
    //            reference.child("Pools").childByAutoId().updateChildValues([
    //                "entryFee" : pool.entryFee,
    //                "id" : pool.id,
    //                "percentageOfWinners" : pool.percentageOfWinners,
    //                "spotsLeft" : pool.spotsLeft,
    //                "totalSpots" : pool.totalSpots,
    //                "totalWinningAmount" : pool.totalWinningAmount])
    //        }
    //    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "PoolCell", bundle: nil), forCellWithReuseIdentifier: poolCellId)
        reference = Database.database().reference()
        login()
        
        fetchDataAndReload()
        
        reference.child("Pools").observe(.childChanged) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let changedPool = Pool(dictionary: dictionary)
            guard let indexOfPoolToReplace = self.pools.firstIndex(where: {$0.id == changedPool.id}) else { return }
            print("⚠️", changedPool, "⚠️", indexOfPoolToReplace)
            self.pools.remove(at: indexOfPoolToReplace)
            self.pools.insert(changedPool, at: indexOfPoolToReplace)
            self.collectionView.reloadItems(at: [IndexPath(item: indexOfPoolToReplace, section: 0)])
        }
        
    }
    @IBAction func test(_ sender: Any) {
        let uid = Auth.auth().currentUser!.uid
        print(uid)
    }
    
    fileprivate func joinPoolOrCreateTeam(id: Int) {
        let uid = Auth.auth().currentUser!.uid
        reference.child("Teams").child(uid).observeSingleEvent(of: .value) { (snaphot) in
            let snap = snaphot.value as? [String: Any]
            if snap == nil { // no team has been created
                self.navigationController?.pushViewController(CoinSelectionController(), animated: true)
            } else {
                self.joinPool(with: id)
            }
        }
        
    }
    
    
    fileprivate func join(pool: Pool, userID: String) {
        
        self.reference.child("Pools").child(pool.id).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary  = snapshot.value as? [String: Any] else { return }
            print(dictionary, "🚦")
            let pool = Pool(dictionary: dictionary)
            if pool.spotsLeft >= 1 {
                self.reference.child("Pools").child(pool.id).updateChildValues(["spotsLeft" : (pool.spotsLeft - 1)])
                self.reference.child("Teams").child(userID).child("poolsJoined").updateChildValues(["\(pool.id)": Date().timeIntervalSince1970])
            } else {
                print("Pool already filled, sorry!")
            }
        }
    }
    
    fileprivate func joinPool(with id: Int) {
        
        let pool = pools[id]
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        reference.child("Teams").child(userID).child("poolsJoined").observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as? [String: Any]
            
            if snap == nil {
                
                self.join(pool: pool, userID: userID)
                
            } else { // user has joined
                
                if snap!["\(pool.id)"] == nil { // user has not joined this pool
                    
                    self.join(pool: pool, userID: userID)
                    
                } else {
                    print("ALREADY JOINED ⚠️")
                }
                
            }
//            let dictionary = snapshot.value as? [String: Any]
//            print("🥛", dictionary, "🥛")
//            if dictionary == nil {
//                print("player has not joined ANY pools before this")
//
//                self.reference.child("Pools").child(pool.id).observeSingleEvent(of: .value) { (snapshot) in
//                    guard let dictionary  = snapshot.value as? [String: Any] else { return }
//                    print(dictionary, "🚦")
//                    let pool = Pool(dictionary: dictionary)
//                    if pool.spotsLeft >= 1 {
//                        self.reference.child("Pools").child(pool.id).updateChildValues(["spotsLeft" : (pool.spotsLeft - 1)])
//                        self.reference.child("Teams").child(userID).child("poolsJoined").updateChildValues(["\(pool.id)": Date().timeIntervalSince1970])
//                    } else {
//                        print("Pool already filled, sorry!")
//                    }
//                }
//            } else {
//                print("player has joined a pool and now we must check if he has joined our specific pool")
//            }
            
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
        }
    }
    
    fileprivate func login() {
        if Auth.auth().currentUser?.uid == nil {
            Firebase.Auth.auth().signInAnonymously { (user, error) in
                if error != nil {
                    print(error!.localizedDescription, "❗️")
                }
                print(user!.user.uid, "✅")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension PoolsListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        joinPoolOrCreateTeam(id: indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pools.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: poolCellId, for: indexPath) as! PoolCell
        cell.pool = pools[indexPath.row]
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
    
}


