//
//  AppDelegate.swift
//  Draft11
//
//  Created by Sanket Ray on 8/13/19.
//  Copyright © 2019 Sanket Ray. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        FirebaseApp.configure()
        
        var rootViewController = UIViewController()
        
        if Auth.auth().currentUser?.uid == nil {
            print("User not logged in")
            rootViewController = LoginController()
        } else {
            rootViewController = PoolsListController()
        }
        
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


let randomNames = [ "Lovetta Mariotti", "Callie Shemwell", "Vertie Mayville", "China Lollar", "August Bridgewater", "Natividad Uy", "Sherril Bivens", "Will Madonna", "Virgen Champ", "Rickey Kennemer", "Eveline Arrellano", "Gabrielle Foerster", "Corie Almendarez", "Elvin Desch", "Jerold Metzger", "Alton Mallory", "Claire Borgman", "Hellen Quackenbush", "Shanna Ku", "Gonzalo Fagen", "Brad Darlington", "Tyler Turvey", "Laurice Hartline", "Berna Billy", "Cornelia Solorzano", "Karena Hendon", "Shantel Eveland", "Shanon Keeth", "Tameka Cooks", "Jeffie Feliciano", "Aubrey Kanode", "Terrell Walkup", "Ellis Swarts", "Irish Langton", "Lowell Bomberger", "Lyndon Foran", "Maragaret Raminez", "Wilda Baillargeon", "Reyna Muncie", "Lamont Bowie", "Elenore Grubb", "Star Collett", "Lurlene Acheson", "Mitzie Ferraro", "Ola Whitting", "Danette Riera", "Noella Meachum", "Cathy Venturini", "Katrina Burkle", "Moses Cyphers", "Therese Stutes", "Refugia Brumback", "Shellie Gabrielson", "Ginny Alsup", "Gloria Rockwell", "Wilford Dizon", "Shameka Lorenzen", "Lovie Grillo", "Grady Sarver", "Marylin Curfman", "Season Fowlkes", "Gerardo Celestine", "Vergie Zank", "Aida Tobias", "Dionna Kissel", "Gwenn Moye", "Merilyn Hertzler", "Ami Stalnaker", "Callie Bianco", "Sophia Paredes", "Elouise Daniel", "Wesley Beachy", "Shiloh Heesch", "Patsy Bagnell", "Latoria Maddy", "Joycelyn Preusser", "Mayola Britton", "Mathilde Jaco", "Adah Reinhard", "Yadira Candler", "Sun Erben", "Genesis Swank", "Ozell Teter", "Diann Lucero", "Elna Earnhardt", "Nova Sergio", "Lilly Severino", "Regan Flood", "Steffanie Aten", "Zenaida Dossett", "Dwain Leaf", "Adelle Nagao", "Felton Magruder", "Ava Ostler", "Melda Leeper", "Mack Leyendecker", "Ileen Garlock", "Queen Mulcahy", "Cornell Dao", "Connie Hoffmeister" ]
