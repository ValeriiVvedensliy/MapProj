//
//  ViewController.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 23.04.2022.
//

import UIKit
import GoogleMaps
import MapKit
import Polyline
import RealmSwift
import RxFlow
import RxRelay

class MapsViewController: UIViewController, Stepper {
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var firstPointField: UITextField!
  @IBOutlet weak var secondPointField: UITextField!
  @IBOutlet weak var startRouteButton: UIButton!
  @IBOutlet weak var stopRouteButton: UIButton!
  @IBOutlet weak var showRouteButton: UIButton!

  let coordinate = CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273)
  var firstMarket: GMSMarker!
  var secondMarket: GMSMarker!
  var geoCoder: CLGeocoder?
  var route: GMSPolyline?
  var locationManager: CLLocationManager?
  var routePath: GMSMutablePath?
  var firstCoordinate: CLLocationCoordinate2D!
  var secondCoordinate: CLLocationCoordinate2D!
  var currentPolyline: GMSPolyline?
  var stepsCoords:[CLLocationCoordinate2D] = []
  var timer = Timer()
  var marker: GMSMarker?
  var iPosition: Int = 0
  var realm = try! Realm()
  var isRouteStopped = false
  var steps = PublishRelay<Step>()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    configureMap()
    configureLocationManager()
    setUpView()
  }

  private func setUpView() {
    setUpTextField(placeholde: Constants.firstTextField, textField: firstPointField)
    setUpTextField(placeholde: Constants.secondTextField, textField: secondPointField)

    setUpButtons(text: Constants.startButtonText, button: startRouteButton)
    setUpButtons(text: Constants.stopButtonText, button: stopRouteButton)
    setUpButtons(text: Constants.showRouteButtonText, button: showRouteButton)

    startRouteButton.enebledState()
    stopRouteButton.dissableState()
    showRouteButton.enebledState()

    startRouteButton.addTarget(self, action: #selector(startRoute), for: .touchUpInside)
    stopRouteButton.addTarget(self, action: #selector(stopRoute), for: .touchUpInside)
    showRouteButton.addTarget(self, action: #selector(showRoute), for: .touchUpInside)
  }

  private func configureLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.requestAlwaysAuthorization()
  }
  
  private func configureMap() {
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    mapView.camera = GMSCameraPosition(target: coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    locationManager?.stopUpdatingLocation()
    self.marker = GMSMarker(position: coordinate)
    self.marker!.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
    self.marker!.icon = self.imageWithImage(
      image: #imageLiteral(resourceName: "arrow"),
      scaledToSize: CGSize(width: 30.0, height: 30.0))
    self.marker!.map = self.mapView
  }

  private func setUpTextField(placeholde: String, textField: UITextField){
    textField.backgroundColor = .white
    textField.placeholder = placeholde
    textField.isUserInteractionEnabled = false
    textField.layer.cornerRadius = textField.frame.height / 2
  }

  private func setUpButtons(text: String, button: UIButton){
    button.backgroundColor = .white
    button.setTitle(text, for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.layer.cornerRadius = button.frame.height / 2
  }

  @objc
  func startRoute() {
    guard let firstCoordinate = firstCoordinate,
          let secondCoordinate = secondCoordinate else { return }

    isRouteStopped = false
    currentPolyline?.map = nil
    self.mapView.moveCamera(GMSCameraUpdate.zoomIn())
    self.setRoute(from: firstCoordinate, to: secondCoordinate)
    showRouteButton.dissableState()
    startRouteButton.dissableState()
    stopRouteButton.enebledState()

    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (_) in
        self.playAnimation()
    })
    
    RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
  }

  @objc
  func stopRoute() {
    isRouteStopped = true
    saveData()
    clearMap()
  }

  @objc
  func showRoute() {
    let routes = try! Realm().objects(Route.self)
    guard let firstPoin = routes.first?.firstPoint,
          let secondPoint = routes.first?.secondPoint else { return }
    
    firstCoordinate = CLLocationCoordinate2D(latitude: firstPoin.latitude, longitude: firstPoin.longitude)
    firstMarket = GMSMarker(position: firstCoordinate)
    secondCoordinate = CLLocationCoordinate2D(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
    secondMarket = GMSMarker(position: secondCoordinate)

    firstPointField.text = "    \(String(describing: firstPoin.name))"
    secondPointField.text = "    \(String(describing: secondPoint.name))"
    
    
    self.setRoute(from: firstCoordinate, to: secondCoordinate)
    self.setPoint(name: firstPoin.name, country: firstPoin.country, mapView: mapView, manulMarker: firstMarket)
    self.setPoint(name: secondPoint.name, country: secondPoint.country, mapView: mapView, manulMarker: secondMarket)
  }

  private func setRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
    let source = MKMapItem(placemark: MKPlacemark(coordinate: from))
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
    let request = MKDirections.Request()
    request.source = source
    request.destination = destination
    request.requestsAlternateRoutes = false
    let directions = MKDirections(request: request)
    directions.calculate(completionHandler: {[weak self] (response, error) in
      if let res = response {
        guard let self = self else { return }

        self.show(polyline: self.googlePolylines(from: res))
      }
    })
  }

  private func googlePolylines(from response: MKDirections.Response) -> GMSPolyline {
    let route = response.routes[0]
    var coordinates = [CLLocationCoordinate2D](
      repeating: kCLLocationCoordinate2DInvalid,
      count: route.polyline.pointCount)
    route.polyline.getCoordinates(
      &coordinates,
      range: NSRange(location: 0, length: route.polyline.pointCount))
    let polyline = Polyline(coordinates: coordinates)
    let encodedPolyline: String = polyline.encodedPolyline
    let path = GMSPath(fromEncodedPath: encodedPolyline)
    currentPolyline = GMSPolyline(path: path)
    stepsCoords = decodePolyline(encodedPolyline)!

    return currentPolyline!
  }

  private func show(polyline: GMSPolyline) {
    polyline.strokeColor = UIColor.blue
    polyline.strokeWidth = 3
    polyline.map = mapView
  }

  func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }

  func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
    let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
    let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
    let tLat: Float = Float((toLoc.latitude).degreesToRadians)
    let tLng: Float = Float((toLoc.longitude).degreesToRadians)
    let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
    if degree >= 0 {
      return degree - 180.0
    }
    else {
      return (360 + degree) - 180
    }
  }

  private func playAnimation(){
    if iPosition <= self.stepsCoords.count - 1 && isRouteStopped == false {
      let position = self.stepsCoords[iPosition]
      self.marker?.position = position
      mapView.camera = GMSCameraPosition(target: position, zoom: 15, bearing: 0, viewingAngle: 0)
      self.marker!.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
      if iPosition != self.stepsCoords.count - 1 {
        self.marker!.rotation = CLLocationDegrees(exactly: self.getHeadingForDirection(fromCoordinate: self.stepsCoords[iPosition], toCoordinate: self.stepsCoords[iPosition+1]))!
      }
      
      if iPosition == self.stepsCoords.count - 1 {
        iPosition = 0;
        saveData()
        clearMap()
        isRouteStopped = true
        timer.invalidate()
      }
      
      iPosition += 1
    }
  }

  private func clearMap() {
    showRouteButton.enebledState()
    startRouteButton.enebledState()
    stopRouteButton.dissableState()
    currentPolyline?.map = nil
    firstPointField.text = nil
    secondPointField.text = nil
    firstMarket.map = nil
    secondMarket.map = nil
  }
  
  private func saveData() {
    try? realm.write {
        realm.deleteAll()
    }

    try! realm.write {
      let routes = Route()
      let firstPoint = Coordinate()
      firstPoint.name = firstMarket.title!
      firstPoint.country = firstMarket.snippet!
      firstPoint.latitude = firstCoordinate.latitude
      firstPoint.longitude = firstCoordinate.longitude

      let secondPoint = Coordinate()
      secondPoint.name = secondMarket.title!
      secondPoint.country = secondMarket.snippet!
      secondPoint.latitude = secondCoordinate.latitude
      secondPoint.longitude = secondCoordinate.longitude

      routes.firstPoint = firstPoint
      routes.secondPoint = secondPoint
      realm.add(routes)
    }
  }
}

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
              let firstText = self.firstPointField.text,
              let secondText = self.secondPointField.text,
              let name = places?.last?.name,
              let country = places?.last?.country else { return }

        if firstText.isEmpty {
          self.firstCoordinate = coordinate
          self.firstPointField.text = "    \(String(describing: name))"
          self.firstMarket = GMSMarker(position: coordinate)
          self.setPoint(name: name, country: country, mapView: mapView, manulMarker: self.firstMarket)
        } else if secondText.isEmpty {
          self.secondCoordinate = coordinate
          self.secondPointField.text = "    \(String(describing: name))"
          self.secondMarket = GMSMarker(position: coordinate)
          self.setPoint(name: name, country: country, mapView: mapView, manulMarker: self.secondMarket)
        }
    })
  }

  func setPoint(name: String, country: String, mapView: GMSMapView, manulMarker: GMSMarker) {
    manulMarker.title = name
    manulMarker.snippet = country
    manulMarker.map = mapView
  }
}

extension MapsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error)
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      guard status == .authorizedWhenInUse else {
          return
      }
      locationManager?.startUpdatingLocation()
      mapView.isMyLocationEnabled = true
      mapView.settings.myLocationButton = true
  }
}

private enum Constants {
  // String
  static let firstTextField = "   Откуда едем ?"
  static let secondTextField = "    Куда едем ?"
  static let startButtonText = "Начать маршрут"
  static let stopButtonText = "Остановить"
  static let showRouteButtonText = "Последний маршрут"
}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
