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

    fileprivate var authHandle: FIRAuthStateDidChangeListenerHandle!
    var user: FIRUser?
    
    deinit {
        
        FIRAuth.auth()?.removeStateDidChangeListener(authHandle)
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
        authHandle = FIRAuth.auth()?.addStateDidChangeListener { (auth: FIRAuth, user: FIRUser?) in
            
            // Check if there is a current user.
            if let activeUser = user {
                
                // check if the current app user is the current FIRUser.
                if self.user != activeUser {
                    
                    self.user = activeUser
                }
            }
            else {
                
                // User must sign in.
                self.loginSession()
            }
        }
    }
    
    func loginSession() {
        
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
}
