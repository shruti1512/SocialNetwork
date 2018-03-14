//
//  DataService.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/7/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import Foundation
import Firebase
import KeychainSwift

//This contains the referance to our databse in Firebase
let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // Database Referances - These contain the referances to child 'users' and 'posts' in our database
    private (set) var REF_USERS: DatabaseReference = DB_BASE.child("users")
    private (set) var REF_POSTS: DatabaseReference = DB_BASE.child("posts")
    var likesRef: DatabaseReference!
        
    var REF_USER_CURRENT: DatabaseReference {
        let userID = KeychainSwift().get(KEY_UID)
        let user = REF_USERS.child(userID!)
        return user
    }

    //Storage Referances
    private (set) var REF_POST_IMAGES: StorageReference = STORAGE_BASE.child("post-pics")
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        
        //This method creates a child in 'users' node with uid and updates its child values using the userData
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func uploadImageToFirebaseClousStorage(image: UIImage, completion: @escaping (String) -> Void) {
        
        guard let imgData = UIImageJPEGRepresentation(image, 0.2) else { return }
        let imageUid = NSUUID().uuidString
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        REF_POST_IMAGES.child(imageUid).putData(imgData, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("Unable to upload image on Google Cloud \(error.localizedDescription)")
                completion("")
            }
            else {
                guard let downloadUrl = metadata?.downloadURL()?.absoluteString else { return }
                completion(downloadUrl)
            }
        }
    }

    func downloadImageFromFirebaseCloudStorage(imageUrl: String, completion: @escaping () -> Void) {
        
        // Create a reference from a Google Cloud Storage URI
        let gsRef = Storage.storage().reference(forURL: imageUrl)
        gsRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if let error = error {
                print("Unable to download image from Google Cloud Storage: \(error.localizedDescription)")
            }
            else {
                guard let imgData = data else { return }
                if let img = UIImage(data: imgData) {
                    FeedVC.imageCache.setObject(img, forKey: imageUrl as NSString)
                    completion()
                    print("Image downloaded from Google Cloud Storage for url: \(imageUrl)")
                }
            }
        })
    }
    
    func getPosts(completion: @escaping ([Post]) -> Void) {
        
        //We observe an event to fetch data for Posts using observe method and receive the callback in snapshot object of FIRDataSnapshot
        REF_POSTS.observe(DataEventType.value, with: { (snapshot) in
            
            print(snapshot.value!)
            
            /* A FIRDataSnapshot contains data from a Firebase Database location. Any time you read Firebase data, you receive the data as a FIRDataSnapshot.
             FIRDataSnapshots are passed to the blocks you attach with observeEventType:withBlock: or observeSingleEvent:withBlock:. */
            
            //Here we traverse the entire snapshot for all its children thus we get an array of DataSnapshot as each child is also a DataSnapshot and then we create Post object using value of each snapshot
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                var postsArray = [Post]()
                for snap in snapshot {
                    let post_key = snap.key
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let post = Post(postKey: post_key, postData: postDict)
                        postsArray.append(post)
                    }
                }
                completion(postsArray)
            }
        })
    }

    func addPostDataToFirebase(post: Dictionary<String, AnyObject>, completion: @escaping () -> Void) {
        
        let firebaseRef = REF_POSTS.childByAutoId()
        firebaseRef.setValue(post)
        completion()
    }
    
    func checkIfPostIsLiked(_ postKey: String, completion: @escaping (Bool) -> Void) {
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(postKey)
        var isLiked = false
        likesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                isLiked = false
            }
            else {
                isLiked = true
            }
            completion(isLiked)
        }
    }
    
    func updateLikesForPost(_ postKey: String, completion: @escaping (Bool) -> Void) {
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(postKey)
        var isLiked = false

        likesRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if let _ = snapshot.value as? NSNull {
                isLiked = true
                self?.likesRef.setValue(true)
            }
            else {
                isLiked = false
                self?.likesRef.removeValue()
            }
            
            completion(isLiked)
        }
    }
    
    
}
