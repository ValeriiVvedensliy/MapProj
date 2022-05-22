//
//  MapsViewController+Reactive.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 20.05.2022.
//

import RxCocoa
import RxSwift

extension Reactive where Base: MapsViewController {
  var fromPoint: Binder<Point?> {
    Binder(base) { screen, point in
      screen.setFromPoint(point: point)
    }
  }

  var toPoint: Binder<Point?> {
    Binder(base) { screen, point in
      screen.setToPoint(point: point)
    }
  }

  var coordinates: Binder<Coordinates?> {
    Binder(base) { screen, coordinates in
      screen.startRoute(coordinates: coordinates)
    }
  }

  var show: Binder<Coordinates?> {
    Binder(base) { screen, coordinates in
      guard let coordinates = coordinates else { return }

      screen.setRoute(from: coordinates.from, to: coordinates.to)
    }
  }

  var clear: Binder<Void> {
    Binder(base) { screen, _ in
      screen.clearMap()
    }
  }
}
