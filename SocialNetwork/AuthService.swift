//
//  AuthService.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/14/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import Foundation
import UIKit
import Firebase

typealias Completion = (_ errmsg: String?, _ data: AnyObject?) -> Void

class AuthService {
    
    static let auth_instance = AuthService()
    private init() {} //This prevents others from using the default '()' initializer for this class.

    //MARK: - Authenticate with Firebase using Email and Password

    func login(withEmail email: String, password: String, onComplete: Completion?) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                guard let errCode = AuthErrorCode(rawValue: error!._code), errCode == .userNotFound else {
                    self.handleFirebaseLoginErrors(error: error!, onComplete: onComplete)
                    return
                }
                self.createAccountForFirstTimeUser(withEmail: email, password: password, onComplete: onComplete)
            }
            else {
                guard let userObj = user else { return }
                print("User signed-in successfuly with email and password")
                onComplete?(nil, userObj)
            }
        }
    }
    
    //MARK: - Create Account on Firebase using Email and Password

    func createAccountForFirstTimeUser(withEmail email: String, password: String, onComplete: Completion?) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                print("New User account created and signed-in successfuly")
                onComplete?(nil, user)
            }
            else {
                self.handleFirebaseLoginErrors(error: error!, onComplete: onComplete)
            }
        })
    }
    
    //MARK: - Firebase Error Handling : Authentication and Create Account

    func handleFirebaseLoginErrors(error: Error, onComplete: Completion?) {
        
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .invalidEmail, .wrongPassword:
                onComplete?("Invalid email or password.", nil)
                break
            case .weakPassword:
                onComplete?("Weak password.", nil)
            case .emailAlreadyInUse, .accountExistsWithDifferentCredential:
                onComplete?("Email already in use.", nil)
                break
            default:
                print("Sign-In User Error: \(error)")
                onComplete?("There is a problem authenticating. Please try again.", nil)
                break
            }
        }
    }

    //MARK: - Authenticate with Firebase using Firebase Credential
    
    func firebaseAuthWithCredential(_ credential: AuthCredential, onComplete: Completion?) {
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("User unable to authenticate with Firebase - \(error.localizedDescription)")
                onComplete?("Authentication failed.", nil)
            }
            else {
                print("User successfully authenticated with Firebase")
                guard let user = user else { return }
                onComplete?(nil, user)
            }
        }
    }

}
