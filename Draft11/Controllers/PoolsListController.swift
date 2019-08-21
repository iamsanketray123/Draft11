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
import GradientLoadingBar
import SkeletonView

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
        
        
        collectionView.isSkeletonable = true
        collectionView.prepareSkeleton { (completed) in
            completed ? (self.collectionView.showAnimatedSkeleton()) : ()
        }
        
        let gradientColorList = [
            #colorLiteral(red: 0.9490196078, green: 0.3215686275, blue: 0.431372549, alpha: 1), #colorLiteral(red: 0.9450980392, green: 0.4784313725, blue: 0.5921568627, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.737254902, blue: 0.7843137255, alpha: 1), #colorLiteral(red: 0.4274509804, green: 0.8666666667, blue: 0.9490196078, alpha: 1), #colorLiteral(red: 0.7568627451, green: 0.9411764706, blue: 0.9568627451, alpha: 1)
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
        }
        
    }
    
    @IBAction func test(_ sender: Any) {
        try! Auth.auth().signOut()
        
    }
    
    fileprivate func checkIfUserHasCreatedATeam(id: Int) {
        let uid = Auth.auth().currentUser!.uid
        reference.child("Teams").child(uid).observeSingleEvent(of: .value) { (snaphot) in
            let snap = snaphot.value as? [String: Any]
            if snap == nil { // no team has been created
                let coinSelectionController = CoinSelectionController()
                coinSelectionController.selectedPool = self.pools[id]
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(coinSelectionController, animated: true)
                }
            } else {
                self.checkIfUserHasJoinedPool(with: id)
            }
        }
        
    }

    
    fileprivate func checkIfUserHasJoinedPool(with id: Int) {
        
        let pool = pools[id]
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        reference.child("Pools").child(pool.id).child("players").observeSingleEvent(of: .value) { (snapshot) in
            let snap = snapshot.value as? [String: Any]
            print("♊️", snapshot, "♊️")
            if snap == nil { // no player has joined the pool yet.
                self.join(pool: pool, userID: userID)
            } else {
                guard let snap = snap else { return }
                for (key, _) in snap {
                    if key == userID { // player has joined this pool
                        print("ALREADY JOINED ⚠️") // probably proceed to next screen with start game button.
                        return
                    }
                }
                self.join(pool: pool, userID: userID)
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
                //                self.reference.child("Teams").child(userID).child("poolsJoined").updateChildValues([pool.id: Date().timeIntervalSince1970])
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

extension PoolsListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return poolCellId
    }
    
    
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pools.count
    }
    
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
