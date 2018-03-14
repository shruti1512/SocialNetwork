//
//  FeedCell.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/6/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var postCaptionTextView: UITextView!
    @IBOutlet weak var postImgView: UIImageView!

    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeImgTapped))
        tapGesture.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tapGesture)
        likeImage.isUserInteractionEnabled = true
    }
    
    @objc func likeImgTapped(sender: UITapGestureRecognizer) {
        
        sender.isEnabled = false
        
        DataService.ds.updateLikesForPost(post.postKey!) { (isLiked) in
            if !isLiked {
                self.likeImage.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
            }
            else {
                self.likeImage.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
            }
            sender.isEnabled = true
        }
    }
    
    func configureCell(postData: Post, img: UIImage? = nil) {
        
        post = postData
        
        //set caption text
        postCaptionTextView.text = postData.caption!
    
        //set no. of likes text
        let likes: String = "\(postData.likes!)"
        let likesText = NSMutableAttributedString.init(string:"Likes \(String(describing: likes))")
        likesText.setAttributes([NSAttributedStringKey.font: UIFont.init(name: "Avenir Next", size: 13.0)!, NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.6)], range: NSMakeRange(0,5))
        likesText.setAttributes([NSAttributedStringKey.font : UIFont.init(name: "Avenir Next", size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.black], range: NSMakeRange(6, likes.count))
        likesLbl.attributedText = likesText
        
        //set image for post
        if img != nil {
            self.postImgView.image = img
        }
        else {
            guard let imgUrl = postData.imageUrl else { return }
            DataService.ds.downloadImageFromFirebaseCloudStorage(imageUrl: imgUrl, completion: {
                self.postImgView.image = img
            })
        }
        
        //set likes image
        DataService.ds.checkIfPostIsLiked(postData.postKey!) { (isLiked) in
            if isLiked {
                self.likeImage.image = UIImage(named: "filled-heart")
            }
            else {
                self.likeImage.image = UIImage(named: "empty-heart")
            }
        }
    }
    
}
