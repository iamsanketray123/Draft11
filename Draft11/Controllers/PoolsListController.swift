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
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var comingSoon: UILabel!
    
    var reference: DatabaseReference!
    var pools = [Pool]()
    let poolCellId = "poolCellId"
    
    lazy var categoryView: CategoryView = {
        let cv = CategoryView()
        cv.poolsListController = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryContainer.addSubview(categoryView)
        categoryView.anchor(top: categoryContainer.topAnchor, left: categoryContainer.leftAnchor, bottom: categoryContainer.bottomAnchor, right: categoryContainer.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        categoryView.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
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
        
    }
    
    fileprivate func joinPoolOrCreateTeam(id: Int) {
        let uid = Auth.auth().currentUser!.uid
        reference.child("Teams").child(uid).observeSingleEvent(of: .value) { (snaphot) in
            let snap = snaphot.value as? [String: Any]
            if snap == nil { // no team has been created
                let coinSelectionController = CoinSelectionController()
                coinSelectionController.selectedPool = self.pools[id]
                self.navigationController?.pushViewController(coinSelectionController, animated: true)
            } else {
                self.joinPool(with: id)
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
                self.reference.child("Teams").child(userID).child("poolsJoined").updateChildValues([pool.id: Date().timeIntervalSince1970])
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
                self.reference.child("Users").child(user!.user.uid).updateChildValues(["userName": "Sanket Ray"])
                print(user!.user.uid, "✅")
            }
        } else {
            print("User already logged in")
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
    
}

let randomNames = [ "Lovetta Mariotti", "Callie Shemwell", "Vertie Mayville", "China Lollar", "August Bridgewater", "Natividad Uy", "Sherril Bivens", "Will Madonna", "Virgen Champ", "Rickey Kennemer", "Eveline Arrellano", "Gabrielle Foerster", "Corie Almendarez", "Elvin Desch", "Jerold Metzger", "Alton Mallory", "Claire Borgman", "Hellen Quackenbush", "Shanna Ku", "Gonzalo Fagen", "Brad Darlington", "Tyler Turvey", "Laurice Hartline", "Berna Billy", "Cornelia Solorzano", "Karena Hendon", "Shantel Eveland", "Shanon Keeth", "Tameka Cooks", "Jeffie Feliciano", "Aubrey Kanode", "Terrell Walkup", "Ellis Swarts", "Irish Langton", "Lowell Bomberger", "Lyndon Foran", "Maragaret Raminez", "Wilda Baillargeon", "Reyna Muncie", "Lamont Bowie", "Elenore Grubb", "Star Collett", "Lurlene Acheson", "Mitzie Ferraro", "Ola Whitting", "Danette Riera", "Noella Meachum", "Cathy Venturini", "Katrina Burkle", "Moses Cyphers", "Therese Stutes", "Refugia Brumback", "Shellie Gabrielson", "Ginny Alsup", "Gloria Rockwell", "Wilford Dizon", "Shameka Lorenzen", "Lovie Grillo", "Grady Sarver", "Marylin Curfman", "Season Fowlkes", "Gerardo Celestine", "Vergie Zank", "Aida Tobias", "Dionna Kissel", "Gwenn Moye", "Merilyn Hertzler", "Ami Stalnaker", "Callie Bianco", "Sophia Paredes", "Elouise Daniel", "Wesley Beachy", "Shiloh Heesch", "Patsy Bagnell", "Latoria Maddy", "Joycelyn Preusser", "Mayola Britton", "Mathilde Jaco", "Adah Reinhard", "Yadira Candler", "Sun Erben", "Genesis Swank", "Ozell Teter", "Diann Lucero", "Elna Earnhardt", "Nova Sergio", "Lilly Severino", "Regan Flood", "Steffanie Aten", "Zenaida Dossett", "Dwain Leaf", "Adelle Nagao", "Felton Magruder", "Ava Ostler", "Melda Leeper", "Mack Leyendecker", "Ileen Garlock", "Queen Mulcahy", "Cornell Dao", "Connie Hoffmeister" ]
