import Foundation
import RxCocoa

struct ValidationCellModel: AuthorisationCellModel {
  let result = "ValidationCellModel.Text"
  let isHidden: Driver<Bool>
}
