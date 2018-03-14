//
//  Post.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/7/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    // MARK: - Properties
    private (set) var caption: String?
    private (set) var imageUrl: String?
    private (set) var likes:Int?
    private (set) var postKey: String?
    var postRef: DatabaseReference {
        let postRef = DataService.ds.REF_POSTS.child(postKey!)
        return postRef
    }
    
    // MARK: - Initializers
    init(caption: String, imageUrl: String, likes: Int) {
        self.caption = caption
        self.likes = likes
        self.imageUrl = imageUrl
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>)
    {
        self.postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self.caption = caption
        }
        if let imageUrl = postData["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        if let likes = postData["likes"] as? Int {
            self.likes = likes
        }
    }
    
    /* We have to use the mutating keyword – when we are changing the variables defined in our struct! */
    mutating func adjustLikes(addLike: Bool) {
        if addLike {
            likes = likes! + 1
        }
        else {
            var numLikes = likes!
            numLikes = numLikes - 1

            likes = numLikes > 1 ? numLikes : 0
        }
        
        //Here we update the value of 'likes' child in our 'post' child of 'posts' referance
        postRef.child("likes").setValue(likes)
    }
}
