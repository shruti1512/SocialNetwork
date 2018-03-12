//
//  DataService.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/7/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import Foundation
import Firebase

//This contains the referance to our databse in Firebase
let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // Database Referances - These contain the referances to child 'users' and 'posts' in our database
    private (set) var REF_USERS = DB_BASE.child("users")
    private (set) var REF_POSTS = DB_BASE.child("posts")
    
    //Storage Referances
    private (set) var REF_IMAGES = STORAGE_BASE.child("post-pics")
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        
        //This method creates a child in 'users' node with uid and updates its child values using the userData
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}
