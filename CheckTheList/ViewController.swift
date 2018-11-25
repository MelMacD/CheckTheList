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

class ViewController: UIViewController {

    @IBOutlet weak var usernameFeild: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    
   let rootRef =  Database.database().reference()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func sumbitButton(_ sender: Any) {
        
      
       
    }
 
}

