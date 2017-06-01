//
//  CustomTabBarController.swift
//  Template
//
//  Created by Dylan Miller on 4/17/17.
//  Copyright © 2017 StreetCode. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class CustomTabBarController: UITabBarController {

    fileprivate var authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    
    deinit {
        
        Auth.auth().removeStateDidChangeListener(authHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureAuth()
    }

    func configureAuth() {
        
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        // Listen for changes in the authorization state.
        authHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            // Check if there is a current user.
            if let activeUser = user {
                
                // add user to database if not there
                let rootNode = Database.database().reference()
                let usersNode = rootNode.child("users")
                usersNode.observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if !snapshot.hasChild(activeUser.uid) {
                        
                        let userNode = usersNode.child(activeUser.uid)
                        let values = [
                            "name": activeUser.displayName,
                            "email": activeUser.email,
                            "imageurl": activeUser.photoURL?.absoluteString]
                        userNode.updateChildValues(values, withCompletionBlock: { (error: Error?, database: DatabaseReference) in
                            if let error = error {
                                print(error)
                            }
                            else{
                                userNode.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                                    let userid = snapshot.key
                                    InstaUser.currentUser = InstaUser(id: userid, dictionary: snapshot.value as AnyObject)
                                })
                            }
                        })
                        
                    }
                    else {
                        let userNode = usersNode.child(activeUser.uid)
                        userNode.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                            let userid = snapshot.key
                            InstaUser.currentUser = InstaUser(id: userid, dictionary: snapshot.value as AnyObject)
                        })
                    }
                })
                
                // check if the current app user is the current FIRUser.
                if self.user != activeUser {
                    self.user = activeUser
                }
            }
            else {
                
                // User must sign in.
                self.loginSession()
            }
        })
    }
    
    func loginSession() {
        
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
}
