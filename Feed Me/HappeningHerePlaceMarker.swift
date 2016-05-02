//
//  PlaceMarker.swift
//  Feed Me
//
//  Created by Rob Underwood on 4/30/16.
//  Copyright © 2016 Ron Kliffer. All rights reserved.
//

import UIKit

class HappeningHerePlaceMarker: GMSMarker {
  // 1
  let happeninghereplace: HappeningHerePlace
  
  // 2
  init(happeninghereplace: HappeningHerePlace) {
    self.happeninghereplace = happeninghereplace
    super.init()
    
    position = happeninghereplace.coordinate
    icon = UIImage(named: happeninghereplace.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = kGMSMarkerAnimationPop
  }
}