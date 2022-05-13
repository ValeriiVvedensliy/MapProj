//
//  User.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 13.05.2022.
//

import Foundation
import RealmSwift

class User: Object {
  @objc dynamic var login = ""
  @objc dynamic var password = ""
}
