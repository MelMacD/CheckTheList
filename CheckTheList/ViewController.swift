//
//  ViewController.swift
//  CheckTheList
//
//  Created by Melanie MacDonald on 2018-11-08.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn
import CoreData
import Firebase
import FirebaseAuth




class ViewController: UIViewController, FUIAuthDelegate{

   

    let sb = UIStoryboard(name: "Main", bundle: nil)
    
    let rootRef =  Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()
        
        
       
        
    }
    
    
    func checkLoggedIn() {
        print(1222222222)
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                if let tableViewVC = self.sb.instantiateViewController(withIdentifier: "tableViewVC") as? TabTableViewController{
                    self.present(tableViewVC, animated: true, completion: nil)
                }
               // self.performSegue(withIdentifier: "tableView", sender: self)
            }
                // No user is signed in.
            else{
                print(user?.email)
                self.loginPage()
        }
        }
    }
    func signOut(){
        
      try! Auth.auth().signOut()
      //  print(Auth.auth().currentUser?.email)
       // URLCache.shared.removeAllCachedResponses()
        //URLCache.shared.diskCapacity = 0
        //URLCache.shared.memoryCapacity = 0
    }
    
    @IBAction func signOutButton(_ sender: Any) {
         signOut()
        print("s w")
       
    }
    @IBAction func loginButton(_ sender: UIButton) {
        checkLoggedIn()
    }
    
    
    
}

// Email sign In
extension ViewController{
    
    func loginPage(){
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else{
            return
        }
        
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
           // FUIGoogleAuth(),
            FUIGoogleAuth(),
           // FUITwitterAuth(),
           // FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!),
            ]
        authUI?.providers = providers
        
        
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
        
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        // var userEmail = authDataResult?.user.email
      //  performSegue(withIdentifier: "tableView", sender: self)
        
        if let tableViewVC = sb.instantiateViewController(withIdentifier: "tableViewVC") as? TabTableViewController{
            self.present(tableViewVC, animated: true, completion: nil)
        }
            
            
       
        
    }
}

