import Foundation
import RxDataSources

struct AuthorisationSectionModel: Equatable {
  let items: [AuthorisationCellModel]

  init(items: [AuthorisationCellModel]) {
    self.items = items
  }

  static func == (lhs: AuthorisationSectionModel, rhs: AuthorisationSectionModel) -> Bool {
    lhs.items.count == rhs.items.count
  }
}

extension AuthorisationSectionModel: SectionModelType {
  typealias Item = AuthorisationCellModel

  init(original: Self, items: [Self.Item]) {
    self = original
  }
}
