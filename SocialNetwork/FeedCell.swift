//
//  FeedCell.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/6/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var postCaptionTextView: UITextView!
    @IBOutlet weak var postImgView: UIImageView!

    func configureCell(postData: Post) {
        postCaptionTextView.text = postData.caption
    
        let likes = String(describing: postData.likes)
        let likesText = NSMutableAttributedString.init(string:"Likes \(postData.likes)")
        likesText.setAttributes([NSAttributedStringKey.font: UIFont.init(name: "Avenir Next", size: 13.0)!, NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.6)], range: NSMakeRange(0,5))
        
        likesText.setAttributes([NSAttributedStringKey.font : UIFont.init(name: "Avenir Next", size: 15.0)!, NSAttributedStringKey.foregroundColor: UIColor.black], range: NSMakeRange(6, likes.count))
        
        likesLbl.attributedText = likesText
    }
}
