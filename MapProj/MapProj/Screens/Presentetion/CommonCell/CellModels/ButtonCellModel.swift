import Foundation
import RxCocoa

struct ButtonCellModel: AuthorisationCellModel {
  let title: String
  let actionTitle: String
  let isEnabled: Driver<Bool>
  let isSending: Driver<Bool>
  let onTap: PublishRelay<Void>
}
