import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: ButtonTableViewCell {
  var isEnabled: Binder<Bool> {
    Binder(base) { view, enabled in
      view.isEnabled = enabled
    }
  }

  var isSending: Binder<Bool> {
    Binder(base) { view, sending in
      view.isSending = sending
    }
  }
}
