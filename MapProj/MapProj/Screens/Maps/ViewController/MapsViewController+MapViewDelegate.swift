//
//  MapsViewController+MapViewDelegate.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 19.05.2022.
//

import UIKit
import GoogleMaps

extension MapsViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    if geoCoder == nil {
      geoCoder = CLGeocoder()
    }
    
    geoCoder?.reverseGeocodeLocation(
      CLLocation(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      completionHandler: { [weak self] places, error in
        guard let self = self,
              let name = places?.last?.name,
              let country = places?.last?.country else { return }

        let point = Point(
          name: "    \(String(describing: name))",
          country: country,
          coordinate: coordinate
        )
        
        self.viewModel.input.point.onNext(point)
    })
  }
}
