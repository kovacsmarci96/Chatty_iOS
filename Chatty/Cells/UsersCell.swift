//
//  UsersCell.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 16..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    func setImage(image: UIImage){
        profileImage.image = image
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
    }
    
    func setName(name: String){
        nameLabel.text = name
    }
    
    func setEmail(email: String){
        emailLabel.text = email
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
