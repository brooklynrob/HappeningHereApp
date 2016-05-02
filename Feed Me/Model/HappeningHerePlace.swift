//
//  HappeningHerePlace.swift
//  Happening Here
//
//  Created by Rob Underwood on 5/1/16.
//  Copyright © 2016 TTM Advisors. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class HappeningHerePlace {
  let name: String
  let address: String
  let coordinate: CLLocationCoordinate2D
  let placeType: String
  var photoReference: String?
  var photo: UIImage?
  
  init(dictionary:[String : AnyObject], acceptedTypes: [String])
  {

    let json = JSON(dictionary)
    
    name = json["venue"]["name"].stringValue
    address = json["venue"]["address1"].stringValue
    
    let latitude = (json["venue"]["latitude"]).doubleValue
    let longitude = (json["venue"]["longitude"]).doubleValue

    let lat = latitude as CLLocationDegrees
    let lng = longitude as CLLocationDegrees

    coordinate = CLLocationCoordinate2DMake(lat, lng)
  
    
    // from orginal code -> need to make work
    photoReference = json["photos"][0]["photo_reference"].string
    
    //var foundType = "restaurant"
    //placeType = foundType
 
    placeType = (json["venue"]["venue_type"]).stringValue
    //var foundType = placeType
  }
}
