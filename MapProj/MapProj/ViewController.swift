//
//  ViewController.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 23.04.2022.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
  @IBOutlet weak var mapView: GMSMapView!
  let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
  var marker: GMSMarker?
  var geoCoder: CLGeocoder?
  var route: GMSPolyline?
  var locationManager: CLLocationManager?
  var routePath: GMSMutablePath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpNavigationController()
    configureMap()
    configureLocationManager()
  }

  private func setUpNavigationController() {
    let titleLabel = UILabel()
    titleLabel.text = "Maps"
    titleLabel.textColor = .black
    navigationItem.titleView = titleLabel
    
    let leftBtn = UIButton(frame: CGRect(x: 16, y: 28, width: 28, height: 28))
    leftBtn.tintColor = .blue
    leftBtn.setTitleColor(.blue, for: .normal)
    leftBtn.setTitle("Add Market", for: .normal)
    leftBtn.addTarget(self, action: #selector(addMarket), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    
    let rightBtn = UIButton(frame: CGRect(x: 16, y: 28, width: 28, height: 28))
    rightBtn.tintColor = .blue
    rightBtn.setTitleColor(.blue, for: .normal)
    rightBtn.setTitle("Position", for: .normal)
    rightBtn.addTarget(self, action: #selector(didTapUpdateLocation), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
  }
  
  @objc
  private func addMarket() {
    mapView.animate(toLocation: coordinate)
    if marker == nil {
      marker = GMSMarker(position: coordinate)
      marker?.map = mapView
    }
  }
  
  @objc
  private func didTapUpdateLocation(_ sender: UIButton) {
      locationManager?.requestLocation()
      route?.map = nil
      route = GMSPolyline()
      routePath = GMSMutablePath()
      route?.map = mapView
      
      locationManager?.startUpdatingLocation()
  }

  private func configureLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestAlwaysAuthorization()
  }
  
  private func configureMap() {
    let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 15)
    mapView.camera = camera
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
  }
}

extension ViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    if geoCoder == nil {
      geoCoder = CLGeocoder()
    }
    
    geoCoder?.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { places, error in
      let manulMarker = GMSMarker(position: coordinate)
      manulMarker.title = places?.last?.name ?? ""
      manulMarker.snippet = places?.last?.country ?? ""
      manulMarker.map = mapView
    })
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let location = locations.last else { return }
      
      routePath?.add(location.coordinate)
      route?.path = routePath
      
      let position = GMSCameraPosition.camera(withTarget: location.coordinate , zoom: 15)
      mapView.animate(to: position)
      
      print(location.coordinate)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error)
  }
}
