//
//  MapsViewController+ManagerDelegate.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 19.05.2022.
//

import UIKit
import GoogleMaps

extension MapsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      guard status == .authorizedWhenInUse else {
          return
      }
      locationManager?.startUpdatingLocation()
      mapView.isMyLocationEnabled = true
      mapView.settings.myLocationButton = true
  }
}
