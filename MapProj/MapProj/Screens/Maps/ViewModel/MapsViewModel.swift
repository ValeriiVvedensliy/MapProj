//
//  MapsViewModel.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 18.05.2022.
//

import Foundation
import GoogleMaps
import RxSwift
import RxCocoa
import RxDataSources
import RxFlow
import RealmSwift

public final class MapsViewModel: RxViewModelProtocol, Stepper {
  var realm = try! Realm()

  private(set) var input: Input!
  private(set) var output: Output!
  private let disposeBag = DisposeBag()
  public var steps = PublishRelay<Step>()

  // Input
  private let point = BehaviorSubject<Point?>(value: nil)
  private let startRoute = PublishRelay<Void>()
  private let stopRoute = PublishRelay<Void>()
  private let showRoute = PublishRelay<Void>()
  private let routeIsFinished = PublishRelay<Void>()

  // Output
  private let startRouteButtonIsActive = BehaviorSubject<Bool>(value: true)
  private let stopRouteButtonIsActive = BehaviorSubject<Bool>(value: false)
  private let showRouteButtonIsActive = BehaviorSubject<Bool>(value: true)
  private let toPoint = BehaviorSubject<Point?>(value: nil)
  private let fromPoint = BehaviorSubject<Point?>(value: nil)
  private let coordinates = BehaviorSubject<Coordinates?>(value: nil)
  private let clearMap = BehaviorSubject<Void>(value: Void())
  private let route = BehaviorSubject<Coordinates?>(value: nil)

  public init() {
    input = Input(
      point: point.asObserver(),
      startRoute: startRoute,
      stopRoute: stopRoute,
      showRoute: showRoute,
      routeIsFinished: routeIsFinished
    )

    output = Output(
      startRouteButtonIsActive: startRouteButtonIsActive.asDriver(onErrorJustReturn: true),
      stopRouteButtonIsActive: stopRouteButtonIsActive.asDriver(onErrorJustReturn: false),
      showRouteButtonIsActive: showRouteButtonIsActive.asDriver(onErrorJustReturn: true),
      fromPoint: fromPoint.asDriver(onErrorJustReturn: nil),
      toPoint: toPoint.asDriver(onErrorJustReturn: nil),
      coordinates: coordinates.asDriver(onErrorJustReturn: nil),
      clearMap: clearMap.asDriver(onErrorJustReturn: Void()),
      showRoute: route.asDriver(onErrorJustReturn: nil)
    )

    setupBindings()
  }

  private func setupBindings() {
    setupPoints()
    setupStartRoute()
    setupRouteIsFinished(relay: routeIsFinished)
    setupRouteIsFinished(relay: stopRoute)
    setupShowLastRow()
  }

  private func setupPoints() {
    point
      .withLatestFrom(
        Observable.combineLatest(point, fromPoint, toPoint)
      )
      .bind { [weak self] point, fromPoint, toPoint in
        guard let self = self,
              let point = point else { return }

        if fromPoint == nil {
          self.fromPoint.onNext(point)
        } else if toPoint == nil {
          self.toPoint.onNext(point)
        }
      }
      .disposed(by: disposeBag)
  }

  private func setupStartRoute() {
    startRoute
      .map { _ in false }
      .bind(to: startRouteButtonIsActive)
      .disposed(by: disposeBag)
    
    startRoute
      .map { _ in true }
      .bind(to: stopRouteButtonIsActive)
      .disposed(by: disposeBag)
    
    startRoute
      .map { _ in false }
      .bind(to: showRouteButtonIsActive)
      .disposed(by: disposeBag)

    startRoute
      .withLatestFrom(
        Observable.combineLatest(fromPoint, toPoint)
      )
      .bind { [weak self] fromPoint, toPoint in
        guard let self = self,
              let fromPoint = fromPoint,
              let toPoint = toPoint else { return }
        
        self.coordinates.onNext(Coordinates(from: fromPoint.coordinate, to: toPoint.coordinate))
      }
      .disposed(by: disposeBag)
  }

  private func setupRouteIsFinished(relay: PublishRelay<Void>) {
    relay
      .withLatestFrom(
        Observable.combineLatest(fromPoint, toPoint)
      )
      .bind { [weak self] fromPoint, toPoint in
        guard let self = self,
              let fromPoint = fromPoint,
              let toPoint = toPoint else { return }
        
        self.savePoints(fromPoint: fromPoint, toPoint: toPoint)
        self.startRouteButtonIsActive.onNext(true)
        self.stopRouteButtonIsActive.onNext(false)
        self.showRouteButtonIsActive.onNext(true)
        self.clearMap.onNext(Void())
      }
      .disposed(by: disposeBag)
  }

  private func setupShowLastRow() {
    showRoute
      .bind { [weak self] in
        guard let self = self,
              let points = self.getPoints(),
              let fromPoints = points.first,
              let toPoints = points.last else { return }
        
        self.fromPoint.onNext(fromPoints)
        self.toPoint.onNext(toPoints)
        self.route.onNext(Coordinates(from: fromPoints.coordinate, to: toPoints.coordinate))
      }
      .disposed(by: disposeBag)
  }

  private func savePoints(fromPoint: Point, toPoint: Point) {
    try? realm.write {
      realm.deleteAll()
    }
    
    try! realm.write {
      let routes = Route()

      let fromCoordinate = Coordinate()
      fromCoordinate.name = fromPoint.name
      fromCoordinate.country = fromPoint.country
      fromCoordinate.latitude = fromPoint.coordinate.latitude
      fromCoordinate.longitude = fromPoint.coordinate.longitude

      let toCoordinate = Coordinate()
      toCoordinate.name = toPoint.name
      toCoordinate.country = toPoint.country
      toCoordinate.latitude = toPoint.coordinate.latitude
      toCoordinate.longitude = toPoint.coordinate.longitude
      
      routes.firstPoint = fromCoordinate
      routes.secondPoint = toCoordinate
      realm.add(routes)
    }
  }

  private func getPoints() -> [Point]? {
    let routes = try! Realm().objects(Route.self)
    guard let fromCoordinate = routes.first?.firstPoint,
          let toCoordinate = routes.first?.secondPoint else { return nil }
    
    let fromPoint = mapToPoint(coordinate: fromCoordinate)
    let toPoint = mapToPoint(coordinate: toCoordinate)
    
    return [fromPoint, toPoint]
  }

  private func mapToPoint(coordinate: Coordinate) -> Point {
    return Point(
      name: coordinate.name,
      country: coordinate.country,
      coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    )
  }
}

extension MapsViewModel {
  struct Input {
    let point: AnyObserver<Point?>
    let startRoute: PublishRelay<Void>
    let stopRoute: PublishRelay<Void>
    let showRoute: PublishRelay<Void>
    let routeIsFinished: PublishRelay<Void>
  }

  struct Output {
    let startRouteButtonIsActive: Driver<Bool>
    let stopRouteButtonIsActive: Driver<Bool>
    let showRouteButtonIsActive: Driver<Bool>
    let fromPoint: Driver<Point?>
    let toPoint: Driver<Point?>
    let coordinates: Driver<Coordinates?>
    let clearMap: Driver<Void>
    let showRoute: Driver<Coordinates?>
  }
}
