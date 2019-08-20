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
    
    var reference: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        reference = Database.database().reference()
    }
    
    @IBAction func login(_ sender: Any) {
        Firebase.Auth.auth().signInAnonymously { (user, error) in
            if error != nil {
                print(error!.localizedDescription, "❗️")
            }
            self.reference.child("Users").child(user!.user.uid).updateChildValues(["userName": "Sanket Ray"])
            print(user!.user.uid, "✅")
            self.navigationController?.pushViewController(PoolsListController(), animated: true)
        }
        
    }
    


}
