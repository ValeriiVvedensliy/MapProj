//
//  Buttons+Reactive.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 18.05.2022.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
  var isActive: Binder<Bool> {
    Binder(base) { button, isActive in
      if isActive {
        button.enebledState()
      } else {
        button.dissableState()
      }
    }
  }
}
