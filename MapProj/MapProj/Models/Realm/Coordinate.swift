//
//  Coordinate.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 05.05.2022.
//

import Foundation
import RealmSwift

class Coordinate: Object {
  @objc dynamic var name = ""
  @objc dynamic var country = ""
  @objc dynamic var latitude = 0.0
  @objc dynamic var longitude = 0.0
}

