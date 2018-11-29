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

   
    // mark: Variables
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let rootRef =  Database.database().reference()
   
    let db = Firestore.firestore()
    //mark: Page functions
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()
    }
    
    
    
    // mark: buttons
    // mark: actions
    @IBAction func loginButton(_ sender: UIButton) {
        checkLoggedIn()
    }

}


// sign In Page
extension ViewController{
    
    func loginPage(){
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else{
            return
        }
        
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [
           
            FUIGoogleAuth(),
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
    
    func checkLoggedIn() {
        Auth.auth().addStateDidChangeListener { auth, user in
        if user != nil {
        // User is signed in.
        if let tableViewVC = self.sb.instantiateViewController(withIdentifier: "tableViewVC") as? TabTableViewController{
        self.present(tableViewVC, animated: true, completion: nil)
        }
        // self.performSegue(withIdentifier: "tableView", sender: self)
      //  let currentUserIn = Users(Name: user!.displayName!, idToken: user!.uid, email: user!.email!)
       // let userAlreadyExist = Users.checkUsersList(Name: user!.displayName!, idToken: user!.uid, email: user!.email!)
        let isNewuser = self.checkUsersList(idToken: user!.uid)
            print(isNewuser)
            if isNewuser != true {
                self.newUserEntry(Name:user!.displayName!, idToken:user!.uid, email: user!.email!)
            }
            
        }
        // No user is signed in.
            else{
            
            self.loginPage()
            }
        }
    }
    
    func signOut(){
        try! Auth.auth().signOut()
    }
}



extension ViewController {
    
    func checkUsersList(idToken: String) -> Bool {
        
        
        let docRef = db.collection("UserList").document(idToken)
        var result = 3
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                 result = 1
            } else {
                 result = 0
            }
        }
        if result == 1 {
            return true
        }else{
            return false
        }
        
    }
    
    func newUserEntry(Name:String, idToken:String, email: String){
        
        db.collection("Userlist").document(idToken).setData([
            "name": Name,
            "email": email,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }
}
