//
//  ButtonFacebookLogin.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/3/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit

class CustomLoginButton: UIButton, DropShadow {

    @IBInspectable var isRounded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addDropShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
        
        if isRounded {
            makeBtnRounded()
        }
        else {
            addCornerRadiusToBtn()
        }
    }
    
    func makeBtnRounded() {
        layer.cornerRadius = self.frame.size.width/2
    }
    
    func addCornerRadiusToBtn() {
        layer.cornerRadius = 2.0
    }
    
}
