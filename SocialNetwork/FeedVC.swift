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
    @IBOutlet weak var addPostImgView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    var postImage:UIImage!
    var postCaption: String!

    var postsArray = [Post]()

    //MARK: - View LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.delegate = self
        tblView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        getUserPosts()
    }

    func getUserPosts() {
        
        //We observe an event to fetch data for Posts using observe method and receive the callback in snapshot object of FIRDataSnapshot
        DataService.ds.REF_POSTS.observe(DataEventType.value, with: { (snapshot) in
            
            print(snapshot.value!)
            
            /* A FIRDataSnapshot contains data from a Firebase Database location. Any time you read Firebase data, you receive the data as a FIRDataSnapshot.
            FIRDataSnapshots are passed to the blocks you attach with observeEventType:withBlock: or observeSingleEvent:withBlock:. */
            
            //Here we traverse the entire snapshot for all its children thus we get an array of DataSnapshot as each child is also a DataSnapshot and then we create Post object using value of each snapshot
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.postsArray = []
                for snap in snapshot {
                    let post_key = snap.key
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let post = Post(postKey: post_key, postData: postDict)
                        self.postsArray.append(post)
                    }
                }
            }
            self.tblView.reloadData()

            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        })
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
        feedCell.configureCell(postData: post)
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        postCaption = textField.text
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}












