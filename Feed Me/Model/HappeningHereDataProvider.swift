//
//  HappeningHereDataProvider.swift
//  Happening Here
//
//  Created by Rob Underwood on 5/1/16.
//  Copyright © 2016 TTM Advisors. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON


class HappeningHereDataProvider {
  var photoCache = [String:UIImage]()
  var placesTask: NSURLSessionDataTask?
  var session: NSURLSession {
    return NSURLSession.sharedSession()
  }
  
  func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, radius: Double, types:[String], completion: (([HappeningHerePlace]) -> Void)) -> ()
  {
    var urlString = "https://event-tickets-tracker-runderwood5.cs50.io/api/v1/venues?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true"
    let typesString = types.count > 0 ? types.joinWithSeparator("|") : "food"
    urlString += "&types=\(typesString)"
    urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    
    if let task = placesTask where task.taskIdentifier > 0 && task.state == .Running {
        print("cancel")
        task.cancel()

    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      var placesArray = [HappeningHerePlace]()
      if let aData = data {
        let json = JSON(data:aData, options:NSJSONReadingOptions.MutableContainers, error:nil)
        if let results = json.arrayObject as? [[String : AnyObject]] {
          for rawPlace in results {
            let place = HappeningHerePlace(dictionary: rawPlace, acceptedTypes: types)
            placesArray.append(place)
            if let reference = place.photoReference {
              self.fetchPhotoFromReference(reference) { image in
                place.photo = image
              }
            }
          }
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        completion(placesArray)
      }
    }
    placesTask?.resume()
  }
  
  
  func fetchPhotoFromReference(reference: String, completion: ((UIImage?) -> Void)) -> () {
    if let photo = photoCache[reference] as UIImage? {
      completion(photo)
    } else {
      let urlString = "http://localhost:10000/maps/api/place/photo?maxwidth=200&photoreference=\(reference)"
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      session.downloadTaskWithURL(NSURL(string: urlString)!) {url, response, error in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let url = url {
          let downloadedPhoto = UIImage(data: NSData(contentsOfURL: url)!)
          self.photoCache[reference] = downloadedPhoto
          dispatch_async(dispatch_get_main_queue()) {
            completion(downloadedPhoto)
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            completion(nil)
          }
        }
        }.resume()
    }
  }
}

