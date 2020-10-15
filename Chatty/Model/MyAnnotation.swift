//
//  File.swift
//  Chatty
//
//  Created by Kovács Márton on 2019. 12. 03..
//  Copyright © 2019. Kovács Márton. All rights reserved.
//

import UIKit
import MapKit


final class MyAnnotation: NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var phoneNumber: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    var region: MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        return MKCoordinateRegion(center: coordinate,span: span)
    }
}
