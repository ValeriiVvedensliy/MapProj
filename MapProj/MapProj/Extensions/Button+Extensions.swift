//
//  Button+Extensions.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 30.04.2022.
//

import Foundation
import UIKit

extension UIButton {
  func enebledState() {
    self.isUserInteractionEnabled = true
    self.alpha = 1
  }

  func dissableState() {
    self.isUserInteractionEnabled = false
    self.alpha = 0.5
  }
}
