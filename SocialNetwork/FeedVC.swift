//
//  FeedVC.swift
//  SocialNetwork
//
//  Created by Shruti Sharma on 3/5/18.
//  Copyright © 2018 Shruti Sharma. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase

class FeedVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var captionField: UITextField!

    @IBOutlet weak var addPostImgView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    var postImage:UIImage?
    var postsArray = [Post]()
    
    var currentPost: Post!

    //When you define a static var/let into a class (or struct), that information will be shared among all the instances (or values).
    static let imageCache = NSCache<NSString, UIImage>()

    //MARK: - View LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.delegate = self
        tblView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.getPosts { (postArray) -> () in
            self.postsArray = []
            self.postsArray.append(contentsOf: postArray.reversed())
            let offset = self.tblView.contentOffset
            self.tblView.reloadData()
            //self.tblView.layoutIfNeeded()
            self.tblView.setContentOffset(offset, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Sign Out Event
    @IBAction func signOutTapped(_ sender: Any) {
        
        //Remove user-id from keychain
        let keychain = KeychainSwift()
        keychain.delete("KEY_UID")
        
        //Sign Out user from Firebase
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        //move back to login screen
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Add Image and Add Post Events

    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func addPostTapped(_ sender: Any) {
        
        //Create a POST record in Firebase Database
        guard let captionText = captionField.text, !captionText.isEmpty else {
            print("Caption cannot be empty")
            return
        }
        
        if postImage == nil {
            print("Image cannot be empty")
            return
        }
        else {
        
            DataService.ds.uploadImageToFirebaseClousStorage(image: postImage!, completion: { (downloadUrl) in
                
                let post: Dictionary<String, AnyObject> = [
                    "caption": captionText as AnyObject,
                    "imageUrl": downloadUrl as AnyObject,
                    "likes": 0 as AnyObject,
                    "timestamp": ServerValue.timestamp() as AnyObject]
                
                DataService.ds.addPostDataToFirebase(post: post){ () -> () in
                    self.postImage = nil
                    self.addPostImgView.image = UIImage(named:"add-image")
                    self.captionField.text = ""
                    self.tblView.reloadData()
                }
            })
        }
        
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let feedCell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        
        let post = postsArray[indexPath.row]
        if let postImg = FeedVC.imageCache.object(forKey: post.imageUrl! as NSString) {
            feedCell.configureCell(postData:post, img:postImg)
        }
        else {
            feedCell.configureCell(postData: post)
        }
        return feedCell
    }
    
}

//MARK: - UITableViewDelegate
extension FeedVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340.0
    }
}

//MARK: - UIImagePickerControllerDelegate
extension FeedVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            addPostImgView.image = chosenImage
            postImage = chosenImage
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension FeedVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}











