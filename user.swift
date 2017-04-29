//
//  user.swift
//  Template
//
//  Created by StreetCode Academy on 4/22/17.
//  Copyright © 2017 StreetCode. All rights reserved.
//

import Foundation
class User{
    var id : String?
    var name: String?
    var email:String?
    var imageurl:String?
    init(id:String,dictionary:AnyObject) {
        self.id = id
        self.name = dictionary.object(forKey:"name")as? String
        self.email = dictionary.object(forKey:"email")as? String
        self.imageurl = dictionary.object(forKey:"imageurl")as? String
        
        
    }
    
    
    static var currentUser: User?
    
}

