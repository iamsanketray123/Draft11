//
//  ProfileController.swift
//  Fanrex
//
//  Created by Sanket Ray on 8/25/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ProfileController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userName: UILabel!
    
    var reference : DatabaseReference!
    let options = ["Refresh All Games", "Delete My Portfolio", "Sign Out"]
    let optionsImages = [#imageLiteral(resourceName: "refresh.png"), #imageLiteral(resourceName: "delete.png"), #imageLiteral(resourceName: "exit.png")]
    
    fileprivate func setupTableView() {
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.register(UINib.init(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "cellId")
    }
    
    fileprivate func setupUI() {
        nameTextField.delegate = self
        self.navigationController?.navigationBar.isTranslucent = false
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupUI()
        
        reference = Database.database().reference()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        reference.child("Users").child(userID).observeSingleEvent(of: .value) { (snap) in
            guard let dict = snap.value as? [String: String] else { return }
            UIView.transition(with: self.userName, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.userName.text = dict["userName"]
            })
        }
    }
    
    func displayAlertForRereshingGames() {
        let alert = UIAlertController(title: "Alert", message: "This will refresh all the games and you can play the contests again. Your portfolio will remain unaffected.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (_) in
            self.refreshAllGames()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func refreshAllGames() {
        
        reference.child("Pools").observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let pool = Pool(dictionary: dictionary)
                self.reference.child("Pools").child(pool.id).updateChildValues([
                    "isContestLive" : false,
                    "spotsLeft": pool.totalSpots
                    ])
                self.reference.child("Pools").child(pool.id).child("players").removeValue()
            })
        }
    }
    
    func displayAlertForDeletingPortfolio() {
        let alert = UIAlertController(title: "Alert", message: "This will delete your current portfolio, allowing you to create a new one. If you have joined any contest, your team will be removed and the contest will be stopped.", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (_) in
            self.deleteMyTeam()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func deleteMyTeam() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        reference.child("Teams").child(userID).removeValue()
        reference.child("Pools").observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let pool = Pool(dictionary: dictionary)
                
                if pool.playerUIDs.contains(userID) {
                    self.reference.child("Pools").child(pool.id).child("players").updateChildValues([userID: NSNull()])
                    self.reference.child("Pools").child(pool.id).updateChildValues([
                        "spotsLeft": (pool.spotsLeft + 1),
                        "isContestLive": false
                        ])
                }
            })
        }
        
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            self.navigationController?.setViewControllers([LoginController()], animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func editNameTapped(_ sender: Any) {
        
        if heightConstraint.constant != 132 {
            heightConstraint.constant = 132
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.container.alpha = 1
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func hideContainer() {
        if heightConstraint.constant == 132 {
            heightConstraint.constant = 68
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.container.alpha = 0
            }
        }
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
    }
    
    @IBAction func cancelSavingName(_ sender: Any) {
        hideContainer()
    }
    
    @IBAction func saveName(_ sender: Any) {
        
        if !nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isValidName {
            Alert.showBasic(title: "Alert", message: "Please enter a valid name", vc: self)
        } else {
            guard let userID = Auth.auth().currentUser?.uid else { return }
            userName.text = nameTextField.text
            reference.child("Users").child(userID).updateChildValues(["userName" : nameTextField.text!])
            hideContainer()
            nameTextField.text = nil
        }
    }
    
}

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SettingsCell
        
        cell.option.text = options[indexPath.row]
        cell.optionImage.image = optionsImages[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            displayAlertForRereshingGames()
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.item == 1 {
            displayAlertForDeletingPortfolio()
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            signout()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    
    
}


extension ProfileController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
