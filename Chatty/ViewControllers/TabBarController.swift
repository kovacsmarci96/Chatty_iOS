//
//  TabBarController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 16..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    
    var nameLabel = UILabel()
    var profileImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        fetchUser()
    }
    
    //MARK: Setup the navigation bar
    
    func setNavigationBar(){
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.setHidesBackButton(true, animated: false)

        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .clear
        
        let button = UIBarButtonItem(title: "Logout", style: .plain, target: self,action: #selector(makeLogoutAlerts))
        button.image = (UIImage(named:"LogOut"))
        navigationItem.leftBarButtonItem = button
        
    }
    
    func setNavigationBarWithPicture(user: User){
        
        let titleView = UIView()
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        
        titleView.frame = CGRect(x:0,y:0,width: 100,height: 40)
        titleView.backgroundColor = UIColor(red: 111, green: 151, blue: 215, alpha: 0)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageURl = user.imageURL {
            profileImageView.loadImageUsingCache(urlString: profileImageURl)
        }
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        nameLabel.text = user.username
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
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
                
                self.setNavigationBarWithPicture(user: user)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
    }
    
    //MARK: Handle logging out
    
    @objc func handleLogout() {
     do {
         try Auth.auth().signOut()
     } catch let logoutError {
         print(logoutError)
     }
     self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    func makeLogoutAlerts(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: "Do you really want to sign out?", attributes: titleAttributes)
        alert.setValue(titleString, forKey: "attributedTitle")
        let labelAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.handleLogout()
        })
        let labelAction2 = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(labelAction)
        alert.addAction(labelAction2)
        self.present(alert, animated: true, completion: nil)
    }
    

}
