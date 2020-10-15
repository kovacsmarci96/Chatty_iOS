//
//  RegisterViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 15..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController{
    @IBAction func editingDidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBOutlet weak var profileImage2: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    var activityIndicator : UIActivityIndicatorView!
    
    //MARK: Main view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        setupToHideKeyboardOnTapOnView()
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
       
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Register and upload info of the user
    
    func uploadUserInfo(Username: String, Email: String, imageURL: String){
        let currentUser = Auth.auth().currentUser?.uid
        
        let reference = Database.database().reference().child("users").child(currentUser!)
        let values = ["username": userNameTextField.text!, "email": emailTextField.text!, "profileImageURL": imageURL]
        
        reference.updateChildValues(values, withCompletionBlock: { (err, reference) in
            
            if err != nil {
                print(err!)
                return
            }
            
            let user = User()
            user.username = self.userNameTextField.text!
            user.email = self.userNameTextField.text!
            user.imageURL = imageURL
            
            print("Saved user successfully into Firebase db")
        })
    }
    
    func handleRegister(completion:@escaping((String?) -> () )){
        guard let email = emailTextField.text, let password = passwordTextfield.text else {
            print("This is not valid")
            return
        }
        let username = userNameTextField.text
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if error != nil {
                print(error!)
                self?.activityIndicator.isHidden = true
                self?.showAlerts()
                return
            } else {
                let profileimageurl = NSUUID().uuidString + ".jpg"
                let storageReference = Storage.storage().reference().child("profile_Images").child(profileimageurl)
                if let uploadData = self!.profileImage.image?.jpegData(compressionQuality: 0.1){
                    storageReference.putData(uploadData, metadata: nil) { (metadata, error) in
                        storageReference.downloadURL(completion: { (url, error) in
                            if let profileImageURL = url?.absoluteString {
                                self!.uploadUserInfo(Username: username!, Email: email, imageURL: profileImageURL)
                                completion(profileimageurl)
                            }
                        })
                    }
                }
            }
        }
    }
    
    @objc func register(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        handleRegister(completion: { (str) in
            self.activityIndicator.stopAnimating()
            self.openMain()
        })
    }
    
    //MARK: Setup gestures
    
    func setupGestureRecognizers() {
        profileImage.isUserInteractionEnabled = true
        profileImage2.isUserInteractionEnabled = true
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer( target: self, action: #selector(handleProfileImageView)))
        profileImage2.addGestureRecognizer(UITapGestureRecognizer( target: self, action: #selector(handleProfileImageView)))
        registerButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(register)))
    }
    
    //MARK: Open the main view
    
    func openMain(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    //MARK: Make alerts
    
    func showAlerts() {
        let email = emailTextField.text!
        let username = userNameTextField.text!
        let password = passwordTextfield.text!
        
        if username.count == 0 {
            self.makeAlerts(title: "Username is empty!", message: "Please enter your username!")
        }
        if email.count == 0 {
            self.makeAlerts(title: "Email is empty!", message: "Please enter your email address!")
        }
        if password.count == 0 {
            self.makeAlerts(title: "Password is empty!", message: "Please enter your password!")
        }
        if password.count < 6 {
            self.makeAlerts(title: "Password is incorrect", message: "Your password must be at least 6 charachter long!")
        }
        if !email.contains("@") {
            self.makeAlerts(title: "Email is not containing @ !", message: "Please enter a valid email!")
        }
        self.makeAlerts(title: "Email is already in use!", message: "Please choose another email!")
        
    }
}
