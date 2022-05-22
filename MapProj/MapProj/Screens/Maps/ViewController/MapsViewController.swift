import UIKit
import GoogleMaps
import MapKit
import Polyline
import RealmSwift
import RxSwift
import RxCocoa

class MapsViewController: UIViewController {
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var firstPointField: UITextField!
  @IBOutlet weak var secondPointField: UITextField!
  @IBOutlet weak var startRouteButton: UIButton!
  @IBOutlet weak var stopRouteButton: UIButton!
  @IBOutlet weak var showRouteButton: UIButton!
  private let disposeBag = DisposeBag()
  
  var viewModel: MapsViewModel!
  var marker: GMSMarker!
  var geoCoder: CLGeocoder?
  var locationManager: CLLocationManager?
  var routePath: GMSMutablePath?
  var route: GMSPolyline?
  var timer = Timer()
  var stepsCoords:[CLLocationCoordinate2D] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpView()
    configureLocationManager()
    configureMap()
    setupMarket()
    setupBindigs()
  }

  private func setUpView() {
    setUpTextField(placeholde: Constants.firstTextField, textField: firstPointField)
    setUpTextField(placeholde: Constants.secondTextField, textField: secondPointField)

    setUpButtons(text: Constants.startButtonText, button: startRouteButton)
    setUpButtons(text: Constants.stopButtonText, button: stopRouteButton)
    setUpButtons(text: Constants.showRouteButtonText, button: showRouteButton)
  }

  private func setupBindigs() {
    setupBindButtons()
    setupBindPoint()
    setupBindMapsLogick()
  }

  private func setupBindButtons() {
    viewModel.output.startRouteButtonIsActive
      .drive(startRouteButton.rx.isActive)
      .disposed(by: disposeBag)

    viewModel.output.stopRouteButtonIsActive
      .drive(stopRouteButton.rx.isActive)
      .disposed(by: disposeBag)

    viewModel.output.showRouteButtonIsActive
      .drive(showRouteButton.rx.isActive)
      .disposed(by: disposeBag)

    startRouteButton.rx.tap
      .map { _ in Void() }
      .bind(to: viewModel.input.startRoute)
      .disposed(by: disposeBag)

    stopRouteButton.rx.tap
      .map { _ in Void() }
      .bind(to: viewModel.input.stopRoute)
      .disposed(by: disposeBag)

    showRouteButton.rx.tap
      .map { _ in Void() }
      .bind(to: viewModel.input.showRoute)
      .disposed(by: disposeBag)
  }

  private func setupBindPoint() {
    viewModel.output.fromPoint
      .drive(rx.fromPoint)
      .disposed(by: disposeBag)

    viewModel.output.toPoint
      .drive(rx.toPoint)
      .disposed(by: disposeBag)

    viewModel.output.coordinates
      .drive(rx.coordinates)
      .disposed(by: disposeBag)
  }

  private func setupBindMapsLogick() {
    viewModel.output.clearMap
      .drive(rx.clear)
      .disposed(by: disposeBag)

    viewModel.output.showRoute
      .drive(rx.show)
      .disposed(by: disposeBag)
  }

  func setFromPoint(point: Point?) {
    guard let point = point else { return }

    firstPointField.text = point.name
    setMarket(point: point)
  }

  func setToPoint(point: Point?) {
    guard let point = point else { return }

    secondPointField.text = point.name
    setMarket(point: point)
  }

  func startRoute(coordinates: Coordinates?) {
    guard let coordinates = coordinates else { return }

    mapView.moveCamera(GMSCameraUpdate.zoomIn())
    setRoute(from: coordinates.from, to: coordinates.to)
    
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (_) in
      self.playAnimation()
    })
    
    RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
  }

  func setRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
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
        
        self.show(polyline: self.getPolylines(from: res))
      }
    })
  }

  func clearMap() {
    timer.invalidate()
    firstPointField.text = ""
    secondPointField.text = ""
    mapView.clear()
    setupImageForMarket()
  }

  private func setMarket(point: Point)  {
    let market = GMSMarker(position: point.coordinate)
    market.title = point.name
    market.snippet = point.country
    market.map = mapView
  }

  private func show(polyline: GMSPolyline) {
    polyline.strokeColor = UIColor.blue
    polyline.strokeWidth = 3
    polyline.map = mapView
  }

  private func getPolylines(from response: MKDirections.Response) -> GMSPolyline {
    let route = response.routes[0]
    var coordinates = [CLLocationCoordinate2D](
      repeating: kCLLocationCoordinate2DInvalid,
      count: route.polyline.pointCount
    )
    
    route.polyline.getCoordinates(
      &coordinates,
      range: NSRange(location: 0, length: route.polyline.pointCount)
    )

    let polyline = Polyline(coordinates: coordinates)
    let encodedPolyline: String = polyline.encodedPolyline
    let path = GMSPath(fromEncodedPath: encodedPolyline)
    stepsCoords = decodePolyline(encodedPolyline)!
    
    return GMSPolyline(path: path)
  }

  private func playAnimation() {
    guard let position = stepsCoords.first else {
      viewModel.input.routeIsFinished.accept(Void())
      return
    }

    stepsCoords.remove(at: 0)
    marker?.position = position
    mapView.camera = GMSCameraPosition(target: position, zoom: 15, bearing: 0, viewingAngle: 0)
    marker!.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
    guard let toPosition = stepsCoords.first else { return }
    marker!.rotation = CLLocationDegrees( exactly: getHeadingForDirection(from: position,to: toPosition))!
  }

  private func getHeadingForDirection(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D
  ) -> Float {
    let fLat: Float = Float((from.latitude).degreesToRadians)
    let fLng: Float = Float((to.longitude).degreesToRadians)
    let tLat: Float = Float((to.latitude).degreesToRadians)
    let tLng: Float = Float((to.longitude).degreesToRadians)
    let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
    guard degree >= 0 else { return (360 + degree) - 180 }
    
    return degree - 180.0
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

  private func configureLocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.allowsBackgroundLocationUpdates = true
    locationManager?.requestAlwaysAuthorization()
  }
  
  private func configureMap() {
    mapView.isMyLocationEnabled = true
    mapView.delegate = self
    mapView.camera = GMSCameraPosition(
      target: CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273),
      zoom: 15,
      bearing: 0,
      viewingAngle: 0
    )

    locationManager?.stopUpdatingLocation()
  }

  private func setupMarket() {
    marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 37.34033264974476, longitude: -122.06892632102273))
    marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
    setupImageForMarket()
  }

  private func setupImageForMarket() {
    let image = #imageLiteral(resourceName: "arrow")
    let size = CGSize(width: 30.0, height: 30.0)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    marker.icon = newImage
    marker.map = mapView
  }
}

private enum Constants {
  // String
  static let firstTextField = "Maps.From".localizationString
  static let secondTextField = "Maps.To".localizationString
  static let startButtonText = "Maps.Stop.Route".localizationString
  static let stopButtonText = "Maps.Start.Route".localizationString
  static let showRouteButtonText = "Maps.Show.Route".localizationString
}
