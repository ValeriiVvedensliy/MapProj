import Foundation
import RxSwift
import UIKit

class RxTableViewCell<CellModel>: UITableViewCell {
  internal var disposeBag = DisposeBag()

  override func prepareForReuse() {
    super.prepareForReuse()

    disposeBag = DisposeBag()
  }

  func config(item: CellModel) { }
}
