//
//  ViewController.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 2/23/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FirebaseAuth

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* Your app can only have one person logged in at a time. We represent each person logged into your app with AccessToken.current. The LoginManager of Facebook SDK sets this token for you and when it sets current it also automatically writes it to a keychain cache. The AccessToken contains userId which is used to identify the user.
         */
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
        }
        else {
            //addFBLoginButton()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addFBLoginButton() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
    }

}

//MARK: - Authenticate with Firebase
func firebaseAuth(_ credential: AuthCredential) {
    
    // authenticate with Firebase using the Firebase credential
    Auth.auth().signIn(with: credential) { (user, error) in
        if let error = error {
            print("User unable to authenticate with Firebase - \(error.localizedDescription)")
            return
        }
        print("User successfully authenticated with Firebase")
    }

}

//MARK: - LoginButtonDelegate

extension LoginVC: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
       
        switch result {
            
        case .failed(let error):
            print("User unable to authenticate with Facebook - \(error.localizedDescription)")
        case .cancelled:
            print("User cancelled Facebook authentication")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("User successfully authenticated with Facebook")
            print("User granted permissions for \(grantedPermissions) and declined permissions for \(declinedPermissions)")
            
            /* After a user successfully signs in,
             the facebook access token for the signed-in user is used to create a Firebase credential
            */
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            firebaseAuth(credential)
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
}

