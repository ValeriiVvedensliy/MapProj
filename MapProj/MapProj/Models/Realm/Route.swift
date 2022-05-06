//
//  Route.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 05.05.2022.
//

import Foundation
import RealmSwift

class Route: Object {
  @objc dynamic var firstPoint: Coordinate!
  @objc dynamic var secondPoint: Coordinate!
}

