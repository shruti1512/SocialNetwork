//
//  ButtonFacebookLogin.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/3/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit

class FancyButton: UIButton, DropShadow {

    @IBInspectable var isDropShadow: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isDropShadow {
            addDropShadow()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
    }
    
}
