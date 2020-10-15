//
//  ChatMessageCell.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 30..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import AVFoundation
import AVKit

class ChatMessageCell: UICollectionViewCell{
    
    var messageLogController : ChatViewController?
    var message: Message?
    var user: User?
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleviewRightAnchor: NSLayoutConstraint?
    var bubbleviewLeftAnchor: NSLayoutConstraint?
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let playButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named:"play")
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImage : UIImageView = {
        let image =  UIImageView()
        image.image = UIImage(named: "send")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.isHidden = true 
        return image
    }()
    
    let messageImage : UIImageView = {
        let image =  UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 16
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.isUserInteractionEnabled = true
    
        return image
    }()
    
    let mapView : MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 16
        map.layer.masksToBounds = true
        map.mapType = .standard
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isPitchEnabled = false
        map.isRotateEnabled = false
        return map
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImage)
        
        setMapView()
        setMessageImage()
        setPlayButton()
        setActivityIndicator()
        setProfileImage()
        setMessageBubbleView()
        setTextView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setTextView() {
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setMessageBubbleView() {
        bubbleviewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -8)
        bubbleviewRightAnchor?.isActive = true
        
        bubbleviewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        bubbleWidthAnchor =  bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setProfileImage() {
        profileImage.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 8).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func setActivityIndicator() {
        bubbleView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setPlayButton() {
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
    }
    
    func setMessageImage() {
        bubbleView.addSubview(messageImage)
        messageImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImage.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImage.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImage.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        messageImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoom)))
    }
    
    func setMapView() {
        mapView.delegate = self
        bubbleView.addSubview(mapView)
        mapView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicator.stopAnimating()
    }
    
    var playerLayer: AVPlayerLayer?
    var player : AVPlayer?
    
    @objc func handlePlay(){
        if let videoURLString = message?.videoURL, let url = NSURL(string: videoURLString){
            let videoURL = url.absoluteURL
            player = AVPlayer(url: videoURL!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            playButton.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    @objc func handleZoom(tapGesture: UITapGestureRecognizer){
        if message?.videoURL != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView{
            self.messageLogController?.performZoom(startImageView: imageView)
        }
    }
    
}

