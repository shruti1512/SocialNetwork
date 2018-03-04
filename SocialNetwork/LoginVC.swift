//
//  ViewController.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 2/23/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var pswdTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var pswdErrorLbl: UILabel!

    //MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLoginView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* //Code to add Facebook Default Login Button
    func addFBLoginButton() {
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
   */
    
    //MARK: - Additional set up for login view

    func setUpLoginView() {
        
        emailErrorLbl.isHidden = true
        pswdErrorLbl.isHidden = true
        
        emailTextField.delegate = self
        pswdTextField.delegate = self
        
        /* Your app can only have one person logged in at a time. We represent each person logged into your app with AccessToken.current. The LoginManager of Facebook SDK sets this token for you and when it sets current it also automatically writes it to a keychain cache. The AccessToken contains userId which is used to identify the user.
         */
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
        }
        else {
        }

    }

    
    //MARK: - Login Button Tap Events

    @IBAction func signInBtnTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, let pswd = pswdTextField.text else { return}
        
        checkEmailAddressValidation()
        checkPasswordValidation()
        
//        Auth.auth().signIn(withEmail: email, password: pswd) { (user, error) in
//            // ...
//        }
    }
    
    
    @IBAction func facebookLoginBtnTapped(_ sender: Any) {
        
        let loginMgr = LoginManager()
        loginMgr.logIn(readPermissions: [.publicProfile], viewController: self) { loginResult in
            
            switch loginResult {
            case .failed(let error):
                print("User unable to authenticate with Facebook - \(error.localizedDescription)")
            case .cancelled:
                print("User cancelled Facebook authentication")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("User successfully authenticated with Facebook")
                print("User granted permissions for \(grantedPermissions) and declined permissions for \(declinedPermissions)")
                
                /* After a user successfully signs in,
                 the facebook access token for the signed-in user is used to create a Firebase credential
                 */
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                self.firebaseAuth(credential)
            }
        }
    }

    //MARK: - Authenticate with Firebase
    func firebaseAuth(_ credential: AuthCredential) {
        
        // authenticate with Firebase using the Firebase credential
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("User unable to authenticate with Firebase - \(error.localizedDescription)")
                return
            }
            print("User successfully authenticated with Firebase")
        }
    }
    
    //MARK: - Email and Password Validation

    // Validate email string
    // - parameter email: A String that rappresent an email address
    // - returns: A Boolean value indicating whether an email is valid.
    func isValidEmail(_ email: String?) -> Bool {
        
        guard email != nil else { return false }

        // There’s some text before the @
        // There’s some text after the @
        // There’s at least 2 alpha characters after a .

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    func checkEmailAddressValidation() {
        if !isValidEmail(emailTextField.text!) {
            emailErrorLbl.text = "Please enter a vaild email address."
            emailErrorLbl.isHidden = false
            emailTextField.changeBorderColor(isError: true)
        }
        else {
            emailErrorLbl.isHidden = true
            emailTextField.changeBorderColor(isError: false)
        }
    }
    
    func isValidPassword(_ pswd: String?) -> Bool {
        guard pswd != nil else { return false }
        
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,20}")
        return passwordTest.evaluate(with: pswd)
    }
    
    func checkPasswordValidation() {
        if !isValidPassword(pswdTextField.text!) {
            pswdErrorLbl.text = "Password must be 8-20 characters with at least 1 uppercase and lowercase letters and 1 digit."
            pswdErrorLbl.isHidden = false
            pswdTextField.changeBorderColor(isError: true)
        }
        else {
            pswdErrorLbl.isHidden = true
            pswdTextField.changeBorderColor(isError: false)
        }
    }
}


//MARK: - LoginButtonDelegate

extension LoginVC: LoginButtonDelegate {
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
       
        switch result {
            
        case .failed(let error):
            print("User unable to authenticate with Facebook - \(error.localizedDescription)")
        case .cancelled:
            print("User cancelled Facebook authentication")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("User successfully authenticated with Facebook")
            print("User granted permissions for \(grantedPermissions) and declined permissions for \(declinedPermissions)")
            
            /* After a user successfully signs in,
             the facebook access token for the signed-in user is used to create a Firebase credential
            */
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            firebaseAuth(credential)
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        /*
        if textField == emailTextField {
            updateViewOnEmailValidation()
        }
        else if textField == pswdTextField {
            updateViewOnPasswordValidation()
        }
         */
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


