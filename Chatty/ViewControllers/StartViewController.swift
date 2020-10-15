//
//  ViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 15..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController {
    
    //MARK: Main view functions

    override func viewDidLoad() {
        handleLoggedin()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: Checks if a user is already logged in
    
    func handleLoggedin(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if Auth.auth().currentUser?.uid != nil {
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
    }
}

