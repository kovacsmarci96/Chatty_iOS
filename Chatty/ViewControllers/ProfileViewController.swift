//
//  ProfileViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 16..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBAction func hideKeyboard(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    @IBOutlet weak var phoneNumber: UITextField!
    
    
    var changedImage : UIImage!
    var tabbarcontroller : TabBarController!
    let activityindicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fetchUser()
        setupToHideKeyboardOnTapOnView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .white
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .clear
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    //MARK: Setup for working
    
    func setup() {
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        userTextField.isUserInteractionEnabled = false
        phoneNumber.isUserInteractionEnabled = false
        
        tabbarcontroller = self.tabBarController as? TabBarController
        changedImage = UIImage()
        
        profileImage.isUserInteractionEnabled = false
        activityindicator.style = .large
        activityindicator.hidesWhenStopped = true
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer( target: self, action: #selector(makeAlert)))
    }
    
    func handleCameraTap() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK: Update profile
    
    func handllePictureChange() {
        activityindicator.startAnimating()
        let profileimageurl = NSUUID().uuidString + ".jpg"
    
        let reference = Storage.storage().reference().child("profile_Images").child(profileimageurl)
        if let uploadData = self.profileImage.image?.jpegData(compressionQuality: 0.1){
            reference.putData(uploadData, metadata: nil) { (metadata, error) in
                reference.downloadURL(completion: { (url, error) in
                    if let profileImageURL = url?.absoluteString {
                        self.updateUserProfile(imageURL: profileImageURL, username: self.userTextField!.text!,phoneNumber: self.phoneNumber!.text!)
                    }
                })
            }}
    }
    
    func updateUserProfile(imageURL: String, username: String, phoneNumber: String){
        let currentUser = Auth.auth().currentUser?.uid
        
        let reference = Database.database().reference().child("users").child(currentUser!)
        print(imageURL)
        let values = ["username": username,"profileImageURL": imageURL, "phoneNumber": phoneNumber]
        
        reference.updateChildValues(values, withCompletionBlock: { (err, reference) in
            let alert = UIAlertController(title: "Profile change", message: "Your profile has been changed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style:.default, handler: nil))
            self.activityindicator.stopAnimating()
            self.present(alert, animated: true, completion: nil)
        })
    }

    //MARK: Load current user
    
    func fetchUser(){
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary

                let user = User()
                user.email = value?["email"] as? String ?? ""
                user.username = value?["username"] as? String ?? ""
                user.imageURL = value?["profileImageURL"] as? String ?? ""
                user.phoneNumber = value?["phoneNumber"] as? String ?? ""
                
                self.profileImage.loadImageUsingCache(urlString: user.imageURL!)
                self.userTextField.text = user.username
                self.emailLabel.text = user.email
                self.phoneNumber.text = user.phoneNumber
            })
        }
    }
    
    //MARK: Handlers
    
    @objc func editTapped(){
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .clear
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tabBarController?.navigationItem.rightBarButtonItem? = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        profileImage.isUserInteractionEnabled = true
        userTextField.isUserInteractionEnabled = true
        phoneNumber.isUserInteractionEnabled = true
    }
    
    @objc func saveTapped(){
        handllePictureChange()
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        profileImage.isUserInteractionEnabled = false
        userTextField.isUserInteractionEnabled = false
        phoneNumber.isUserInteractionEnabled = false
        self.tabbarcontroller.nameLabel.text = userTextField.text
        self.tabbarcontroller.profileImageView.image = changedImage
    }
    
    @objc func makeAlert() {
        let alert = UIAlertController(title: "Change Profile picture", message: "What would you like to use?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler:{
            UIAlertAction in
            self.handleProfileImageView()
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: {
            UIAlertAction in
            self.handleCameraTap()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
