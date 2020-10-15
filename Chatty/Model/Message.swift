//
//  Message.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 20..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var from: String?
    var to: String?
    var timeStamp: String?
    var text: String?
    var imageURL: String?
    var imageWidth: String?
    var imageHeight: String?
    var longitude: String?
    var latitude: String?
    var videoURL: String?
    
    func chatPartnerID() -> String?  {
        return from == Auth.auth().currentUser?.uid ? to : from
    }
}
