//
//  MainViewController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 15..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//
import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer : Timer?
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserMessages()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatCell = tableView.dequeueReusableCell(withIdentifier: "chatID",for: indexPath) as! ChatsCell
        chatCell.message = messages[indexPath.row]
        return chatCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = User()
        let message = messages[indexPath.row]
        let chatparnerID = message.chatPartnerID()
        
        let reference = Database.database().reference().child("users").child(chatparnerID!)
        
        reference.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let username = value["username"] as? String ?? "From not found"
                let email = value["email"] as? String ?? "To not found"
                let profileImage = value["profileImageURL"] as? String ?? "Text is not found"
                let phoneNumber = value["phoneNumber"] as? String ?? ""
                
                user.id = chatparnerID
                user.username = username
                user.email = email
                user.imageURL = profileImage
                user.phoneNumber = phoneNumber
            
                let messageLogController = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
                messageLogController.user = user
                self.navigationController?.pushViewController(messageLogController, animated: true)
            }
        }
    }
    
    //MARK: Reload table
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData() }
    }
    
    //MARK: Load the messages that belongs to the currentuser
    
    func fetchUserMessages() {
        let currentUser = Auth.auth().currentUser?.uid
        let reference = Database.database().reference().child("userMessages").child(currentUser!)
        
        reference.observe(.childAdded) { (snapshot) in
            let messageID = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageID)
            messageReference.observe(.value) { (snapshot) in
                if let value = snapshot.value as? NSDictionary {
                let message = Message()
                let from = value["from"] as? String ?? "From not found"
                let to = value["to"] as? String ?? "To not found"
                let text = value["text"] as? String ?? "Text is not found"
                let timestamp = value["time"] as? String ?? "Timestamp not found"
                let imageurl = value["imageurl"] as? String
                let longitude = value["longitude"] as? String
                let latitude = value["latitude"] as? String
                let videoURL = value["videourl"] as? String
                message.from = from
                message.to = to
                message.timeStamp = timestamp
                message.text = text
                message.imageURL = imageurl
                message.longitude = longitude
                message.latitude = latitude
                message.videoURL = videoURL
                    
                let chatPartnerID : String?
                    
                if message.from == Auth.auth().currentUser?.uid{
                    chatPartnerID = message.to
                } else {
                    chatPartnerID = message.from
                }
                
                if let ID = chatPartnerID {
                    self.messagesDictionary[ID] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) ->
                        Bool in
                        return Double(message1.timeStamp!)! > Double(message2.timeStamp!)!
                    })
                }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
}
