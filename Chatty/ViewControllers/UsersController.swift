//
//  NewMessageViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 16..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class UsersController: UITableViewController {
    
    var users = [User]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        fetchUsers()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userID",for: indexPath) as! UsersCell
        
        let user = users[indexPath.row]
        
        cell.setName(name: user.username!)
        cell.setEmail(email: user.email!)
        
        if let profileImageURL = user.imageURL {
            cell.profileImage.loadImageUsingCache(urlString: profileImageURL, cell: cell)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageLogController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        messageLogController.user = self.users[indexPath.row]
        self.navigationController?.pushViewController(messageLogController, animated: true)
    }
    
    //MARK: Setup the navigation item
    
    func setupNavigationItem() {
        self.tabBarController?.navigationItem.rightBarButtonItem?.tintColor = .clear
        self.tabBarController?.navigationItem.rightBarButtonItem?.isEnabled = false

        navigationItem.title = "Users"
    }
    
    //MARK: Load the registered users

    func fetchUsers() {
        var emailCurrentUser : String = ""
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            emailCurrentUser = value?["email"] as? String ?? ""

        }) { (error) in
            print(error.localizedDescription)
        }
        
        let rootRef = Database.database().reference()
        let query = rootRef.child("users").queryOrdered(byChild: "username")
        query.observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
            let user = User()
            let id = snapshot.key
            let name = value["username"] as? String ?? "Name not found"
            let email = value["email"] as? String ?? "Email not found"
            let imageurl = value["profileImageURL"] as? String ?? "Profile image not found"
            let phoneNumber = value["phoneNumber"] as? String ?? ""
            user.id = id
            user.username = name
            user.email = email
            user.imageURL = imageurl
            user.phoneNumber = phoneNumber
            
            if email != emailCurrentUser{
                self.users.append(user)
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
}
}

