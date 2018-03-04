//
//  CustomTextField.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/3/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        borderStyle = .none
        layer.cornerRadius = 2.0
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.2).cgColor
    }

    func changeBorderColor(isError: Bool) {
        if isError {
            layer.borderColor = UIColor.red.cgColor
        }
        else {
            layer.borderColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.2).cgColor
        }
    }
    
    /* Add padding to the placeholder text */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10.0, dy: 5.0)
    }
    
    /* Add padding to the editable text */
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10.0, dy: 5.0)
    }
}
