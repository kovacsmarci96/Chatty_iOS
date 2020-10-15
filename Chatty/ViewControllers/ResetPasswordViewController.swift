//
//  ResetPasswordViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 12. 10..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBAction func editingEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!, completion: {
            (error) in
            if error != nil {
                print(error!)
            }
            self.makeAlerts(title: "Your password has been reseted.", message: "Please check your email address")
            self.emailTextField.text = ""
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToHideKeyboardOnTapOnView()
    }

}
