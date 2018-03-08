//
//  Post.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/7/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import Foundation

struct Post {
    
    // MARK: - Properties
    private (set) var caption = ""
    private (set) var imageUrl = ""
    private (set) var likes:Int = 0
    private (set) var postKey = ""
    
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
}
