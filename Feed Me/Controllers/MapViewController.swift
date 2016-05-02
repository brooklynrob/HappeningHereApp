//
//  MapViewController.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit


class MapViewController: UIViewController {
  
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func refreshPlaces(sender: AnyObject) {
        fetchNearbyPlaces(mapView.camera.target)
    }
    
    
    var locationManager = CLLocationManager()
  
    //The following the original data provider for the Ray Wenderlich tutorial
    let dataProviderGoogle = GoogleDataProvider()
  
    //The following is the data provider for the Happening Here backend
    let dataProviderHappeningHere = HappeningHereDataProvider()
    let searchRadius: Double = 1000

  
  
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant", "venue", "pollsite"]

  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    //locationManager.delegate = self
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self


  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    // 1
    mapView.clear()
    
    // This is a call to the new data provider
    dataProviderHappeningHere.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      for place: HappeningHerePlace in places {
        // 3

        let marker_happeninghere = HappeningHerePlaceMarker(happeninghereplace: place)
        // 4
        marker_happeninghere.map = self.mapView
      }
    }
    

    //dataProviderGoogle.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
    //  for place: GooglePlace in places {

 
    //    let marker = PlaceMarker(place: place)
    
    //    marker.map = self.mapView
    //  }
    // }
    
    
    


    
    
  }

  
  
  
  func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
    
    let geocoder = GMSGeocoder()
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      
      //Add this line
      self.addressLabel.unlock()
      
      //Rest of response handling
    }
    
    // 1
    let labelHeight = self.addressLabel.intrinsicContentSize().height
    self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
                                        bottom: labelHeight, right: 0)
    
    UIView.animateWithDuration(0.25) {
      //2
      self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
      self.view.layoutIfNeeded()
    }
    
    // 1

    
    // 2
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      if let address = response?.firstResult() {
        
        // 3
        let lines = address.lines as [String]!
        self.addressLabel.text = lines.joinWithSeparator("\n")
        
        // 4
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
  }

}





// MARK: - TypesTableViewControllerDelegate
extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
    fetchNearbyPlaces(mapView.camera.target)
  }
}



extension MapViewController: CLLocationManagerDelegate {
  // 2
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    // 3
    if status == .AuthorizedWhenInUse {
      
      // 4
      locationManager.startUpdatingLocation()
      
      //5
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
      

      
    }
  }
  
  // 6
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      
      // 7
      mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
      // 8
      locationManager.stopUpdatingLocation()
      
      fetchNearbyPlaces(location.coordinate)
    }
    
  }
}



// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {

  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    reverseGeocodeCoordinate(position.target)
  }
  
  func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    addressLabel.lock()
    
    if (gesture) {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
    }
    
    
  }
  
  
  func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
    // 1
    // was --> let placeMarker = marker as! PlaceMarker
    let placeMarker = marker as! HappeningHerePlaceMarker
    
    // 2
    if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
      // 3
      infoView.nameLabel.text = placeMarker.happeninghereplace.name
      
      // 4
      if let photo = placeMarker.happeninghereplace.photo {
        infoView.placePhoto.image = photo
      } else {
        infoView.placePhoto.image = UIImage(named: "generic")
      }
      
      return infoView
    } else {
      return nil
    }
  }
  
  func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
    mapCenterPinImage.fadeOut(0.25)
    return false
  }
  
  func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
    mapCenterPinImage.fadeIn(0.25)
    mapView.selectedMarker = nil
    return false
  }
  
  
  
}