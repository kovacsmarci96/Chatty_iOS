//
//  MessageLogController.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 30..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//
import UIKit
import Firebase
import CoreLocation
import MapKit
import MobileCoreServices
import AVFoundation


class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate{
    
    var user: User!
    var currentUser : User!
    var message = Message()
    var messages = [Message]()
    var longitude = String()
    var latitude = String()
    let locationManager = CLLocationManager()
    var activityIndicator = UIActivityIndicatorView()
    let cellID = "cellId"
    
    let inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let sendButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "send"), for: .normal)
        button.setTitle("Send", for: .normal)
        return button
    }()
    
    let separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(r:220,g:220,b:220)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let underView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let sendView : UIView = {
        let sendContainer = UIView()
        sendContainer.translatesAutoresizingMaskIntoConstraints = false
        return sendContainer
    }()
    
    let cameraImageView : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named:"camera")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let uploadImageView : UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named:"upload")
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.image?.withTintColor(UIColor(r: 0, g: 137, b: 249))
        return imageview
    }()
    
    let locationImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "location")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        setupCollectionView()
        setupLocationManager()
        setupInputField()
        loadMessages()
        navigationItem.title = user.username
        self.setupToHideKeyboardOnTapOnView()
    }
    
    @objc func editingDidEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    //MARK: CollectionView functions
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        cell.messageLogController = self
        cell.message = message
        cell.user = user
    
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = calculateFrameForText(text: text).width + 25
            cell.bubbleWidthAnchor?.isActive = true
            cell.textView.isHidden = false
            cell.mapView.isHidden = true
            cell.playButton.isHidden = true
        } else if message.imageURL != nil && message.videoURL == nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleWidthAnchor?.isActive = true
            cell.textView.isHidden = true
            cell.mapView.isHidden = true
            cell.playButton.isHidden = true
        } else if message.videoURL != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleWidthAnchor?.isActive = true
            cell.textView.isHidden = true
            cell.mapView.isHidden = true
            cell.messageImage.isHidden = false
            cell.playButton.isHidden = false
        } else if message.longitude != nil {
            cell.bubbleWidthAnchor?.constant = 250
            cell.textView.isHidden = true
            cell.messageImage.isHidden = true
            cell.mapView.isHidden = false
            cell.playButton.isHidden = true
            
            let longitude = Double(message.longitude!)
            let latitude = Double(message.latitude!)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
            if message.from == Auth.auth().currentUser?.uid {
                let annotation = MyAnnotation(coordinate: coordinate, title: currentUser.username, subtitle: "Hey I'm here")
                annotation.phoneNumber = currentUser.phoneNumber
                cell.mapView.addAnnotation(annotation)
                cell.mapView.setRegion(annotation.region, animated: true)
            } else {
                let annotation = MyAnnotation(coordinate: coordinate, title: user.username!, subtitle: "Hey I'm here")
                annotation.phoneNumber = user.phoneNumber

                cell.mapView.addAnnotation(annotation)
               cell.mapView.setRegion(annotation.region, animated: true)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        let message = messages[indexPath.item]
        if let text = message.text {
            height = calculateFrameForText(text: text).height + 15
        } else if message.longitude != nil {
            height = 250
        } else if let imageHeight = Double(message.imageHeight!), let imagewidth = Double(message.imageWidth!) {
            height = CGFloat(imageHeight / imagewidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    //MARK: Main view functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: Setup Location manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.longitude = String(location.coordinate.longitude)
            self.latitude = String(location.coordinate.latitude)
        }
    }
    
    func setupLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: Handle photo sendinjg

    @objc func handleCameraTap() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func handlePhotoTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: Handle if a picture or video is selected
    
    func handleImageSelected(info: [UIImagePickerController.InfoKey : Any]){
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage? {
            selectedImageFromPicker = editedImage
        }
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadImageToFirebase(image: selectedImage, completion: { (imageURL) in
                self.handleSendMessageWithImageURL(url: imageURL, image: selectedImage)
            })
        }
    }
    
    func handleVideoSelected(url: URL){
        let filename = NSUUID().uuidString + ".mov"
        let reference = Storage.storage().reference().child("videomessages").child(filename)
        let uploadTask = reference.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            reference.downloadURL(completion: { (url, error) in
                if let thumbnailImage = self.thumbnailImageForFileURL(url: url!){
                    self.uploadImageToFirebase(image: thumbnailImage) { (imageUrl) in
                        self.handleSendMessageWithVideoURL(videoURL: url!.absoluteString,image: thumbnailImage, imageURL: imageUrl)
                    }
                }
            })
        })
        uploadTask.observe(.progress, handler: { (DataSnapshot) in
            self.addActivityIndicator()
        })
        
        uploadTask.observe(.success, handler: { (DataSnapshot) in
            self.activityIndicator.stopAnimating()
        })
    }
    
    //MARK: ImagePickerController
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videourl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            let temporary = createTemporaryURLforVideoFile(url: videourl)
            let url = temporary.absoluteURL!
            handleVideoSelected(url: url)
        } else {
            handleImageSelected(info: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Make temporary
    
    func createTemporaryURLforVideoFile(url: NSURL) -> NSURL {
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        do {
            try FileManager().copyItem(at: url.absoluteURL!, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }

        return temporaryFileURL as NSURL
    }
    
    func thumbnailImageForFileURL(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        return nil
    }
    
    // MARK: Uploading image to Firebase
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (_ imageurl: String) ->()){
        let imageName = NSUUID().uuidString + ".jpg"
        let ref = Storage.storage().reference().child("Message_Images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.1) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                ref.downloadURL(completion: { (url, error) in
                    if let imageURL = url?.absoluteString {
                        completion(imageURL)
                    }
                })
            }
        }
    }
    
    // MARK: Performing zoom on image
    
    var startingFrame: CGRect?
    var backgroundView: UIView?
    var startingImageView : UIImageView?
    
    func performZoom(startImageView: UIImageView){
        
        self.startingImageView = startImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startImageView.superview?.convert(startImageView.frame, to: nil)
        
        let zoomImageView = UIImageView(frame: startingFrame!)
        zoomImageView.image = startImageView.image
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        backgroundView = UIView(frame: keyWindow!.frame)
        backgroundView?.backgroundColor = .black
        backgroundView?.alpha = 0
        
        keyWindow!.addSubview(backgroundView!)
        keyWindow!.addSubview(zoomImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow!.frame.width
            self.backgroundView?.alpha = 1
            zoomImageView.frame = CGRect(x: 0, y: 0, width: keyWindow!.frame.width, height: height)
            zoomImageView.center = keyWindow!.center
        }, completion: nil)
    }
    
    // MARK: Perform zoom out on image
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomOutImageView = tapGesture.view {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                zoomOutImageView.layer.cornerRadius = 16
                zoomOutImageView.layer.masksToBounds = true
                self.backgroundView?.alpha = 0
            })
            {
                (Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    // MARK: Setup the View
    
    func setupCollectionView() {
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 90, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 57, right: 0)
    }
    
    func setupInputField(){
        
        sendView.backgroundColor = UIColor.white
        
        // MARK: Add SubViews
    
        view.addSubview(sendView)
        view.addSubview(cameraImageView)
        view.addSubview(uploadImageView)
        sendView.addSubview(locationImageView)
        sendView.addSubview(sendButton)
        sendView.addSubview(inputTextField)
        sendView.addSubview(separatorLine)
        view.addSubview(underView)
        
        // MARK: Make the Anchors
        
        sendView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sendView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sendView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sendView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        cameraImageView.leftAnchor.constraint(equalTo: sendView.leftAnchor, constant: 8).isActive = true
        cameraImageView.topAnchor.constraint(equalTo: sendView.topAnchor, constant: 15).isActive = true
        cameraImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        cameraImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        uploadImageView.leftAnchor.constraint(equalTo: cameraImageView.rightAnchor, constant: 8).isActive = true
        uploadImageView.topAnchor.constraint(equalTo: sendView.topAnchor, constant: 15).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        locationImageView.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        locationImageView.topAnchor.constraint(equalTo: sendView.topAnchor, constant: 15).isActive = true
        locationImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        locationImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: sendView.rightAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: sendView.topAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalTo: sendView.heightAnchor).isActive = true
      
        inputTextField.leftAnchor.constraint(equalTo: locationImageView.rightAnchor,constant: 10).isActive = true
        inputTextField.topAnchor.constraint(equalTo: sendView.topAnchor, constant: -10).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: sendView.heightAnchor).isActive = true
        
        separatorLine.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: sendView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        underView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        underView.topAnchor.constraint(equalTo: sendView.bottomAnchor).isActive = true
        underView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        underView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // MARK: Add Recognizers
        
        cameraImageView.isUserInteractionEnabled = true
        uploadImageView.isUserInteractionEnabled = true
        locationImageView.isUserInteractionEnabled = true
        cameraImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCameraTap)))
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePhotoTap)))
        locationImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSendLocation)))
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchDown)
        inputTextField.addTarget(self, action: #selector(editingDidEndOnExit), for: .editingDidEndOnExit)
    }
    
    func addActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message){
        if let profileimageURL = self.user.imageURL {
            cell.profileImage.loadImageUsingCache(urlString: profileimageURL)
        }
    
        if message.from == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImage.isHidden = true
            cell.bubbleviewRightAnchor?.isActive = true
            cell.bubbleviewLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImage.isHidden = false
            cell.bubbleviewLeftAnchor?.isActive = true
            cell.bubbleviewRightAnchor?.isActive = false
        }
        if let messageImageURL = message.imageURL {
            cell.bubbleView.backgroundColor = .clear
            cell.messageImage.loadImageUsingCache(urlString: messageImageURL)
            cell.messageImage.isHidden = false
            
        } else {
            cell.messageImage.isHidden = true
        }
    }

    func calculateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    // MARK: - Send message
    
    func handleSend(pValues: [String : String]){
        let userID = user!.id!
        let currentUserID = Auth.auth().currentUser?.uid
        let currentDate = Date()
        let timestamp = String (currentDate.timeIntervalSince1970)

        let reference = Database.database().reference().child("messages")
        let childReference = reference.childByAutoId()
        
        var values = ["from":currentUserID!, "to": userID, "time": timestamp]
        pValues.forEach({values[$0] = $1})
        
        childReference.updateChildValues(values) { (error,ref) in
            let messageID = childReference.key
            let userMessageReference = Database.database().reference().child("userMessages").child(currentUserID!).child(messageID!)
                    userMessageReference.setValue(1)

            let recipentMessageReference = Database.database().reference().child("userMessages").child(userID).child(messageID!)
                recipentMessageReference.setValue(1)
        }
    }
    
    @objc func handleSendMessage(){
        let message = inputTextField.text!
        if message.isEmpty{
            self.makeAlerts(title: "You can't send empty message!", message: "Write something!")
        } else {
            let values = ["text": message]
            handleSend(pValues: values)
            inputTextField.text = ""
        }
        self.view.endEditing(true)
    }
    
    func handleSendMessageWithImageURL(url: String, image: UIImage){
        let values = ["imageurl": url, "imageWidth": image.size.width.description, "imageHeight": image.size.height.description]
        handleSend(pValues: values)
    }
    
    func handleSendMessageWithVideoURL(videoURL: String, image: UIImage, imageURL: String){
        let values = ["videourl": videoURL, "imageWidth": image.size.width.description, "imageHeight":image.size.height.description, "imageurl": imageURL]
        handleSend(pValues: values)
    }
    
    @objc func handleSendLocation(){
        let values = ["longitude": self.longitude, "latitude": self.latitude]
        handleSend(pValues: values)
    }
    
    // MARK: Load current user and messages
    
    func fetchCurrentUser() {
        currentUser = User()
        let id = Auth.auth().currentUser?.uid
        let reference = Database.database().reference().child("users").child(id!)
        
        reference.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let username = value["username"] as? String ?? "From not found"
                let email = value["email"] as? String ?? "To not found"
                let profileImage = value["profileImageURL"] as? String ?? "Text is not found"
                let phoneNumber = value["phoneNumber"] as? String ?? ""
                    
                self.currentUser!.username = username
                self.currentUser!.email = email
                self.currentUser!.imageURL = profileImage
                self.currentUser!.phoneNumber = phoneNumber
            }
        }
    }
    
    func loadMessages() {
    guard let uid = Auth.auth().currentUser?.uid else {
        return
    }
    
    let userMessageReference = Database.database().reference().child("userMessages").child(uid)
    
    userMessageReference.observe(.childAdded, with: {
        (DataSnapshot) in
            let messageID = DataSnapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageID)
            messageReference.observe(.value, with: {
                (DataSnapshot) in
                if let value = DataSnapshot.value as? NSDictionary {
                    let message = Message()
                    let from = value["from"] as? String ?? "From not found"
                    let to = value["to"] as? String ?? "To not found"
                    let text = value["text"] as? String
                    let timestamp = value["time"] as? String ?? "Timestamp not found"
                    let imageurl = value["imageurl"] as? String
                    let imageWidth = value["imageWidth"] as? String
                    let imageHeight = value["imageHeight"] as? String
                    let longitude = value["longitude"] as? String
                    let latitude = value["latitude"] as? String
                    let videoURL = value["videourl"] as? String
                    message.from = from
                    message.to = to
                    message.text = text
                    message.timeStamp = timestamp
                    message.imageURL = imageurl
                    message.imageWidth = imageWidth
                    message.imageHeight = imageHeight
                    message.longitude = longitude
                    message.latitude = latitude
                    message.videoURL = videoURL
                    if message.chatPartnerID() == self.user.id {
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                            self.collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
                        }
                    }
                }
            })
        })
    }
}
