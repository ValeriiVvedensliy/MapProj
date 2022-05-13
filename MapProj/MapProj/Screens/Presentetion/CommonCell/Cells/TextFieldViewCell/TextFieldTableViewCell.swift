import UIKit
import RxSwift
import RxCocoa
import Reusable

class TextFieldTableViewCell: RxTableViewCell<TextFieldCellModel>, NibReusable {
  
  @IBOutlet private var circledViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private var circledView: UIView!
  @IBOutlet private var textField: UITextField!
  
  var isEnabled = true {
    didSet {
      UIView.animate(withDuration: CATransaction.animationDuration()) {
        self.circledView.alpha = self.isEnabled ? 1 : 0.5
        self.isUserInteractionEnabled = self.isEnabled
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setUpView()
  }
  
  override func config(item: TextFieldCellModel) {
    textField.attributedPlaceholder = item.placeholder
      .localizationString
      .aligmentAttributedString(
        foreground: Constants.textFieldForegroundColor,
        aligment: .left,
        sketchLineHeight: Constants.placeholderSketchLineHeight,
        fontSize: 17
      )

    textField.rx.text
      .orEmpty
      .bind(to: item.onTextChanged)
      .disposed(by: disposeBag)

    item.isDisabled
      .map(!)
      .drive(rx.isEnabled)
      .disposed(by: disposeBag)
    
    textField.isAccessibilityElement = true
    textField.accessibilityIdentifier = item.placeholder
  }
  
  private func setUpView() {
    contentView.backgroundColor = Constants.contentViewBackgroundColor
    circledView.backgroundColor = Constants.circledViewBackgroundColor
    circledView.layer.cornerRadius = circledViewHeightConstraint.constant / 2
    textField.textColor = Constants.textFieldTextColor
    textField.backgroundColor = Constants.textFieldBackgroundColor
    textField.tintColor = Constants.textFieldTintColor
    textField.keyboardAppearance = .dark
    textField.enablesReturnKeyAutomatically = false
    textField.keyboardAppearance = .dark
  }
}

private enum Constants {
  // Color
  static let textFieldForegroundColor = UIColor.darkGray.withAlphaComponent(0.2)
  static let contentViewBackgroundColor = UIColor.Purple
  static let circledViewBackgroundColor = UIColor.White
  static let textFieldTextColor = UIColor.Black
  static let textFieldBackgroundColor = UIColor.clear
  static let textFieldTintColor = UIColor.Blue
  
  // Sizes
  static let placeholderSketchLineHeight: CGFloat = 22
}

