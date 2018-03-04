//
//  ButtonFacebookLogin.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/3/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit

class ButtonFacebookLogin: UIButton, DropShadow {

    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
        makeBtnRounded()
    }
    
    func makeBtnRounded() {
        layer.cornerRadius = self.frame.size.width/2
    }
}
