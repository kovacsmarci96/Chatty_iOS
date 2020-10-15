//
//  ChatsCell.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 20..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class ChatsCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    func setImage(image: UIImage){
        profileImage.image = image
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
    }
    
    var user = User()
    var message: Message? {
        didSet {
            setupChatCell()
            if let seconds = Double(message!.timeStamp!) {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeStamp.text = dateFormatter.string(from: timestampDate)
            }
            if message?.imageURL != nil && message?.videoURL == nil {
                messageLabel.text = "Image message"
            } else if message?.longitude != nil{
                messageLabel.text = "Location message"
            } else if message?.videoURL != nil {
                messageLabel.text = "Video message"
            } else {
                messageLabel.text = message!.text
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupChatCell(){
        if let id = message?.chatPartnerID(){
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                if let value = snapshot.value as? NSDictionary {
                    self.user.username = value["username"] as? String ?? ""
                    self.user.email = value["email"] as? String ?? "Email not found"
                    self.user.imageURL = value["profileImageURL"] as? String ?? ""
                    self.nameLabel.text = self.user.username
                    if let imageURL = self.user.imageURL {
                        self.profileImage.loadImageUsingCache(urlString: imageURL, cell: self)
                    }
                }
            })
        }
    }
}
