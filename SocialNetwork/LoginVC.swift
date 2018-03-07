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
import KeychainSwift

class LoginVC: UIViewController {

    //MARK: - Class member variables declaration

    @IBOutlet weak var pswdTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var pswdErrorLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var isKeyboardVisible = false

    //MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLoginView()
        registerForKeyboardNotifications()
        addTapGestureOnScrollView()
    }

    override func viewDidAppear(_ animated: Bool) {
        let keychain = KeychainSwift()
        let userID = keychain.get(KEY_UID)
        if userID != nil {
            print("userID: \(String(describing: userID))")
            moveToFeedScreen()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
//        if let accessToken = AccessToken.current {
//            // User is logged in, use 'accessToken' here.
//        }
//        else {
//        }
    }
    
    func moveToFeedScreen() {
        performSegue(withIdentifier: "FeedVC", sender: nil)
    }
    
    //MARK: - Keyboard Show/Hide Notifications Handling

    func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        let userInfo = notification.userInfo!
        
        //1. When working with keyboards, the dictionary will contain a key called 'UIKeyboardFrameEndUserInfoKey' telling us the frame of the keyboard after it has finished animating. This will be of type NSValue, which in turn is of type CGRect
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        //2. Here we convert the keyboard frame to our view's co-ordinates. This is because rotation isn't factored into the frame, so if the user is in landscape we'll have the width and height flipped – using the convert() method will fix that.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        //3. This code adjusts the bottom content inset of the scroll view by the height of the keyboard. It also sets the scrollIndicatorInsets property of the scroll view to the same value so that the scrolling indicator won’t be hidden by the keyboard.
        if notification.name == Notification.Name.UIKeyboardWillHide {
            isKeyboardVisible = false
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        } else if !isKeyboardVisible{
            isKeyboardVisible = true
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0) ////we use the property contentInset to add more scrollable space at the bottom
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }

    //MARK: - ScrollView Touches Handling

    func addTapGestureOnScrollView() {
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        tapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc func scrollViewTapped() {
        self.view.endEditing(true)
    }
    
    //MARK: - Login With Email And Facebook Events

    @IBAction func signInBtnTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, let pswd = pswdTextField.text else { return}
        
        let emailValidationStatus = checkEmailAddressValidation()
        let pswdValidationStatus = checkPasswordValidation()
        
        if !emailValidationStatus || !pswdValidationStatus {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: pswd) { (user, error) in
            
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .userNotFound:
                        print("this email does not exist so first create an account for this user")
                        self.createAccountForFirstTimeUser(withEmail: email, pswd: pswd)
                    case .wrongPassword:
                        print("Sorry, either your e-mail or password didn't match what we have on file. Try it again?" )
                    default:
                        print("Sign-In User Error: \(error!)")
                    }
                    
                }
            }
            else {
                if let userObj = user {
                    print("User signed-in successfuly with email and password")
                    print("user name: \(String(describing: userObj.displayName))")
                    print("user email: \(String(describing: userObj.email))")
                    guard let user = user else {return}
                    self.storeUserIDInKeyChain(userID: user.uid)
                    self.moveToFeedScreen()
                }
            }
        }
    }
    
    func createAccountForFirstTimeUser(withEmail email: String, pswd: String) {
    
        Auth.auth().createUser(withEmail: email, password: pswd, completion: { (user, error) in
            if error == nil {
                print("New User account created and signed-in successfuly")
                print("user name: \(String(describing: user?.displayName))")
                print("user email: \(String(describing: user?.email))")
                guard let user = user else {return}
                self.storeUserIDInKeyChain(userID: user.uid)
                self.moveToFeedScreen()
            }
            else {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    print("Create User error: \(errCode)")
                }
            }
        })

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
                self.firebaseAuthWithCredential(credential)
            }
        }
    }

    //MARK: - Authenticate with Firebase
    func firebaseAuthWithCredential(_ credential: AuthCredential) {
        
        // authenticate with Firebase using the Firebase credential
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("User unable to authenticate with Firebase - \(error.localizedDescription)")
            }
            else {
                print("User successfully authenticated with Firebase")
                guard let user = user else { return }
                self.storeUserIDInKeyChain(userID: user.uid)
                self.moveToFeedScreen()
            }
        }
    }
    
    //MARK: - Save User ID in Keychain
    func storeUserIDInKeyChain(userID: String) {
       let keychain = KeychainSwift()
       keychain.set(userID, forKey: KEY_UID)
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

    func checkEmailAddressValidation() -> Bool {
        
        emailTextField.resignFirstResponder()
        if !isValidEmail(emailTextField.text!) {
            emailErrorLbl.text = "Please enter a vaild email address."
            emailErrorLbl.isHidden = false
            emailTextField.changeBorderColor(isError: true)
            return false
        }
        else {
            emailErrorLbl.isHidden = true
            emailTextField.changeBorderColor(isError: false)
            return true
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
    
    func checkPasswordValidation() -> Bool{
        
        pswdTextField.resignFirstResponder()
        if !isValidPassword(pswdTextField.text!) {
            pswdErrorLbl.text = "Password must be 8-20 characters with at least 1 uppercase and lowercase letters and 1 digit."
            pswdErrorLbl.isHidden = false
            pswdTextField.changeBorderColor(isError: true)
            return false
        }
        else {
            pswdErrorLbl.isHidden = true
            pswdTextField.changeBorderColor(isError: false)
            return true
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
            firebaseAuthWithCredential(credential)
        }
    }

    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

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


