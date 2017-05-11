//
//  Post.swift
//  Template
//
//  Created by StreetCode Academy on 4/22/17.
//  Copyright © 2017 StreetCode. All rights reserved.
//

import Foundation
class Post{
    var id : String?
    // TODO: Need to save the user ID of the author of the post here.
    var mics: Int?
    var imageurl:String?
    var videourl:String?
    init(id:String,dictionary:AnyObject) {
        self.id = id
        self.mics = dictionary.object(forKey:"mics")as? Int
        self.imageurl = dictionary.object(forKey:"imageurl")as? String
        self.videourl = dictionary.object(forKey:"videourl")as? String
        

    }
    
}
