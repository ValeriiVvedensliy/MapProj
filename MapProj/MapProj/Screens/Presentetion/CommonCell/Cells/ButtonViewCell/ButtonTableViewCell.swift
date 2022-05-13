import UIKit
import RxSwift
import RxCocoa
import Reusable

class ButtonTableViewCell: RxTableViewCell<ButtonCellModel>, NibReusable  {
  @IBOutlet private var spinner: UIActivityIndicatorView!
  @IBOutlet private var rootView: UIView!
  @IBOutlet private var label: UILabel!
  
  private let tapGesture = UITapGestureRecognizer()
  private var titleText = ""
  private var titleActionText = ""

  var isEnabled = true {
    didSet {
      self.rootView.isUserInteractionEnabled = isEnabled
      self.rootView.alpha = isEnabled ? 1 : 0.5
    }
  }

  var isSending = false {
    didSet {
      if isSending {
        startSpinner()
        startAnimation(text: titleActionText)
      } else {
        startAnimation(text: titleText)
        stopSpinner()
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    setUpView()
  }
  
  override func config(item: ButtonCellModel) {
    label.text = item.title.localizationString

    item.isEnabled
      .drive(rx.isEnabled)
      .disposed(by: disposeBag)

    tapGesture.rx.event
      .map { _ in Void() }
      .bind(to: item.onTap)
      .disposed(by: disposeBag)

    item.isSending
      .drive(rx.isSending)
      .disposed(by: disposeBag)
    
    label.text = item.title
    titleText = item.title
    titleActionText = item.actionTitle
  }
  
  private func startSpinner() {
    spinner.isHidden = false
    spinner.startAnimating()
  }

  private func stopSpinner() {
    spinner.isHidden = true
    spinner.stopAnimating()
  }

  private func startAnimation(text: String) {
    UIView.transition(
      with: label,
      duration: CATransaction.animationDuration(),
      options: .transitionCrossDissolve,
      animations: {
        self.label.text = text
      },
      completion: nil
    )
  }
  
  private func setUpView() {
    contentView.backgroundColor = Constants.contentViewBackgroundColor
    rootView.isAccessibilityElement = true
    rootView.layer.cornerRadius = rootView.bounds.height / 2
    rootView.backgroundColor = Constants.rootViewBackgroundColor
    rootView.isUserInteractionEnabled = true
    rootView.addGestureRecognizer(tapGesture)
    spinner.tintColor = Constants.spinnerTintColor
    spinner.color = Constants.spinnerColor
    spinner.isHidden = true
    label.textColor = Constants.labelTextColor
    
    rootView.isAccessibilityElement = true
    rootView.accessibilityIdentifier = "LoginButton"
  }
}

private enum Constants {
  // Colors
  static let contentViewBackgroundColor = UIColor.Purple
  static let rootViewBackgroundColor = UIColor.Blue
  static let spinnerTintColor = UIColor.White
  static let spinnerColor = UIColor.White
  static let labelTextColor = UIColor.White
}
