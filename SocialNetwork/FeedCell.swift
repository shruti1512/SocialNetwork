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
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var postCaptionTextView: UITextView!
    @IBOutlet weak var postImgView: UIImageView!

    func configureCell(postData: Post, img: UIImage? = nil) {
        
        //set caption text
        postCaptionTextView.text = postData.caption!
    
        //set no. of likes text
        let likes: String = "\(postData.likes!)"
        let likesText = NSMutableAttributedString.init(string:"Likes \(String(describing: likes))")
        likesText.setAttributes([NSAttributedStringKey.font: UIFont.init(name: "Avenir Next", size: 13.0)!, NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.6)], range: NSMakeRange(0,5))
        likesText.setAttributes([NSAttributedStringKey.font : UIFont.init(name: "Avenir Next", size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.black], range: NSMakeRange(6, likes.count))
        likesLbl.attributedText = likesText
        
        //set image for caption
        if img != nil {
            self.postImgView.image = img
        }
        else {
            // Create a reference from a Google Cloud Storage URI
            let gsRef = Storage.storage().reference(forURL: postData.imageUrl!)
            gsRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if let error = error {
                    print("Unable to download image from Google Cloud Storage: \(error.localizedDescription)")
                }
                else {
                    guard let imgData = data else { return }
                    if let img = UIImage(data: imgData) {
                        FeedVC.imageCache.setObject(img, forKey: postData.imageUrl! as NSString)
                        self.postImgView.image = img
                        print("Image downloaded from Google Cloud Storage for url: \(postData.imageUrl!)")
                    }
                }
            })
        }
    }
    
}
