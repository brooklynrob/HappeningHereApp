//
//  PlaceMarker.swift
//  Feed Me
//
//  Created by Rob Underwood on 4/30/16.
//  Copyright © 2016 Ron Kliffer. All rights reserved.
//

import UIKit

class PlaceMarker: GMSMarker {
  // 1
  let place: GooglePlace
  
  // 2
  init(place: GooglePlace) {
    self.place = place
    super.init()
    
    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = kGMSMarkerAnimationPop
  }
}