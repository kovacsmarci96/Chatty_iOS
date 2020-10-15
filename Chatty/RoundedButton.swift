//
//  RoundedButton.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 15..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
}
