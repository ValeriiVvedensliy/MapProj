import UIKit
import RxSwift
import RxCocoa
import Reusable

class ValidationTableViewCell: RxTableViewCell<ValidationCellModel>, NibReusable {
  @IBOutlet private var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setUpCell()
  }
  
  override func config(item: ValidationCellModel) {
    label.text = item.result.localizationString
    
    item.isHidden
      .drive(label.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  private func setUpCell() {
    contentView.backgroundColor = Constants.contentViewBackgroundColor
    label.textColor = Constants.labelTextColor
    
    label.isAccessibilityElement = true
    label.accessibilityIdentifier = "ValidationText"
  }
}

private enum Constants {
  // Colors
  static let labelTextColor = UIColor.Red
  static let contentViewBackgroundColor = UIColor.Purple
}
