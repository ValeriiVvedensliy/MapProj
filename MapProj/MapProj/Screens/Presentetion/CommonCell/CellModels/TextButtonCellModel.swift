import Foundation
import RxCocoa

struct TextButtonCellModel: AuthorisationCellModel {
  let title: String
  let isSending: Driver<Bool>
  let onTap: PublishRelay<Void>
}
