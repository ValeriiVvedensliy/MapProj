//
//  FloatingPoint+Extensions.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 22.05.2022.
//

import Foundation

extension FloatingPoint {
  var degreesToRadians: Self { return self * .pi / 180 }
  var radiansToDegrees: Self { return self * 180 / .pi }
}
