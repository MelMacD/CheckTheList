//
//  Users.swift
//  CheckTheList
//
//  Created by Vaibhav Sharma on 2018-11-28.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Users {
    var Name : String?
    var idToken : String?
    var email : String?
  
    
    
    
    init?(Name: String, idToken :String, email: String) {
        self.Name = Name
        self.idToken = idToken
        self.email = email
    }
    
    
    
}



