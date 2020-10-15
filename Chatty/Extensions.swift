//
//  Extensions.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 11. 15..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//MARK: Make it easy to make rounded buttons

@IBDesignable extension UIButton{
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}

//MARK: Make it easy to set the color

extension UIColor {
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat){
        self.init(red: r/255, green:g/255, blue: b/255, alpha: 1)
    }
}

//MARK: Make it easy to make rounded Views

@IBDesignable extension UIView{
    @IBInspectable var cornerRadius1: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}

extension UIViewController
{
    //MARK: Keyboard appear and disappear
    
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
      if let userInfo = notification.userInfo,
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            UIView.animate(withDuration: duration, animations: {
             if self.view.frame.origin.y == 0 {
                 self.view.frame.origin.y -= keyboardSize.height-30
             }
                self.view.layoutIfNeeded()
            })
        }
      }

    @objc func keyboardWillHide(notification: Notification) {
      if let userInfo = notification.userInfo,
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
        UIView.animate(withDuration: duration) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
          self.view.layoutIfNeeded()
        }
      }
    }
    
    

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    //MARK: Making alerts
    
    func makeAlerts(title: String, message: String) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 18)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.red]
        let messageString = NSAttributedString(string: message, attributes: messageAttributes)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let labelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(labelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: Handling profile image change for RegisterViewController

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleProfileImageView(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        self.present(picker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage? {
            selectedImage = editedImage
        }
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            selectedImage = originalImage
        }
        
        if let selectedImage2 = selectedImage {
            profileImage.image = selectedImage2
            profileImage.contentMode = .scaleAspectFill
            profileImage.layer.cornerRadius = 115
            profileImage2.image = selectedImage
            profileImage2.contentMode = .scaleAspectFill
            profileImage2.layer.cornerRadius = 50
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension UIImage {
    
    //MARK: Fuction to scale Pictures up or Down
    
    func scale(to size: CGSize) -> UIImage {
      let renderer = UIGraphicsImageRenderer(size: size)
      return renderer.image(actions: { rendererContext in
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      })
    }
}


@IBDesignable extension UIImageView{
    //MARK: Make rounded pictures
    
    @IBInspectable var cornerRadius2: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    //MARK: Function to cache the images so the app doesn't have to download it everytime
    
    func loadImageUsingCache(urlString: String) {
        
        self.image = nil
        let key = urlString as NSString
        
        if let cachedImage = imageCache.object(forKey: key) as? UIImage {
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler:  { (data,response,error) in
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage,forKey: key)
                        self.image = downloadedImage
                    }
            }
            }).resume()
    }



    func loadImageUsingCache(urlString: String, cell: UsersCell) {
        
        self.image = nil
        let key = urlString as NSString
        
        if let cachedImage = imageCache.object(forKey: key) as? UIImage {
            cell.setImage(image: cachedImage)
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler:  { (data,response,error) in
            if error != nil{
                print(error!)
                return
            }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage,forKey: key)
                        
                        cell.setImage(image: downloadedImage)
                    }
            }
            }).resume()
    }
    
    func loadImageUsingCache(urlString: String, cell: ChatsCell) {
        
        self.image = nil
        let key = urlString as NSString
        
        if let cachedImage = imageCache.object(forKey: key) as? UIImage {
            cell.setImage(image: cachedImage)
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler:  { (data,response,error) in
            if error != nil{
                print(error!)
                return
            }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage,forKey: key)
                        
                        cell.setImage(image: downloadedImage)
                    }
            }
            }).resume()
    }
}

//MARK: Handling mapview to add annotations and open the maps application

extension ChatMessageCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MyAnnotation {
          let reusableId = "MyAnnotation"
          var markerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reusableId) as? MKMarkerAnnotationView
          
          if markerAnnotationView == nil {
            markerAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reusableId)
            markerAnnotationView?.canShowCallout = true
        
            
            let calloutButton = UIButton(type: .detailDisclosure)
            markerAnnotationView?.rightCalloutAccessoryView = calloutButton
          } else {
            markerAnnotationView?.annotation = annotation
          }
          
          return markerAnnotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let myAnnotation = view.annotation as? MyAnnotation
        
       guard let coordinate = view.annotation?.coordinate else {
         return
       }

       let geocoder = CLGeocoder()
       let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

       geocoder.reverseGeocodeLocation(location) { placemarks, error in
         if let error = error {
           print("Error: \(error.localizedDescription)")
         }

         guard let placemarks = placemarks, placemarks.count != 0 else {
           return
         }

         let clPlacemark = placemarks.first!
         let placemark = MKPlacemark(placemark: clPlacemark)
         let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = view.annotation?.title!
        mapItem.phoneNumber = myAnnotation?.phoneNumber
         
        
         var mapItems = [MKMapItem]()
         mapItems.append(MKMapItem.forCurrentLocation())
         mapItems.append(mapItem)
        
        let latitude = Double(self.message!.latitude!)
        let longitude = Double(self.message!.longitude!)
        let coordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: 0.05, longitudinalMeters: 0.05)
         let launchOptions: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
         ]
         MKMapItem.openMaps(with: mapItems, launchOptions: launchOptions)
       }
     }
}

//MARK: Handling profile image change for ProfileViewController

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker,animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage? {
            selectedImage = editedImage
        }
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            selectedImage = originalImage
        }
        
        if let selectedImage2 = selectedImage {
            changedImage = selectedImage2
            profileImage.image = selectedImage2
            profileImage.contentMode = .scaleAspectFill
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


