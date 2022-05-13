import Foundation
import RxSwift
import RxCocoa

struct TextFieldCellModel: AuthorisationCellModel {
  let placeholder: String
  let onTextChanged: AnyObserver<String>
  let isDisabled: Driver<Bool>
}
