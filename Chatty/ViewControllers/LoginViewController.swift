//
//  LoginViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 16..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var activityIndicator : UIActivityIndicatorView!
    
    @IBAction func editingDidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameSwitch: UISwitch!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: Main view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToHideKeyboardOnTapOnView()
        loginButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(login)))
        usernameSwitch.setOn(UserDefaults.standard.bool(forKey: "emailSaved"), animated: false)
        if usernameSwitch.isOn {
            emailTextfield.text = UserDefaults.standard.value(forKey: "email") as? String
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: User login to Chatty
    
    func handleLogin(completion:@escaping((String?) -> () )) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            print("This is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error != nil {
                print(error.debugDescription)
                self?.activityIndicator.isHidden = true
                self!.showalerts()
                return
            } else {
                self!.openMain()
            }
        }
    }
    
    @objc func login(){
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        handleLogin(completion: { (str) in
            self.activityIndicator.stopAnimating()
            self.openMain()
        })
        UserDefaults.standard.set(usernameSwitch.isOn, forKey: "emailSaved")
        if usernameSwitch.isOn {
            UserDefaults.standard.set(emailTextfield.text, forKey:"email")
        }
    }
    
    //MARK: Open main screen
    
    func openMain(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    //MARK: Show alerts

    func showalerts(){
        let email = emailTextfield.text!
        let password = passwordTextfield.text!
        
        if email.count == 0{
            self.makeAlerts(title: "Email is empty!", message: "Please enter your email address!")
        }
        if password.count == 0{
            self.makeAlerts(title: "Password is empty!", message: "Please enter your password!")
        }
        if !email.contains("@") {
            self.makeAlerts(title: "Email is not containing @ !", message: "Please enter a valid email!")
        }
        self.makeAlerts(title: "There is no user with this email or password!", message: "Please correct it or register!")
    }
}

