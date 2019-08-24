//
//  LoginController.swift
//  Draft11
//
//  Created by Sanket Ray on 8/20/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet weak var trophyTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var trophy: UIImageView!
    @IBOutlet weak var draft11CenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var worldsBiggestCenterConstraint: NSLayoutConstraint!
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        reference = Database.database().reference()
        trophy.alpha = 0
    }
    
    fileprivate func executeAnimation() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            self.trophyTopConstraint.constant = 180
            self.draft11CenterConstraint.constant = 0
            self.worldsBiggestCenterConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.trophy.alpha = 1
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        executeAnimation()
    }
    
    @IBAction func login(_ sender: Any) {
        
        
        let userName = UIDevice.current.name
        print(userName, "🍶", userName.contains("’"))
        let a = userName.split(separator: "’")
        print(a[0])
        
        
        Firebase.Auth.auth().signInAnonymously { (user, error) in
            if error != nil {
                print(error!.localizedDescription, "❗️")
            }
            self.reference.child("Users").child(user!.user.uid).updateChildValues(["userName": "\(a[0])"])
            print(user!.user.uid, "✅")
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(PoolsListController(), animated: true)
            }
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        trophy.alpha = 0
        trophyTopConstraint.constant = 60
        draft11CenterConstraint.constant = -300
        worldsBiggestCenterConstraint.constant = 300
    }
    


}
