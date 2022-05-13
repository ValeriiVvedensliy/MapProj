import Foundation
import UIKit

extension String {
  var localizationString: String {
    NSLocalizedString(
      self,
      tableName: nil,
      bundle: Bundle(for: AuthorisationFlow.self),
      value: "",
      comment: ""
    )
  }
  
  func aligmentAttributedString(
    foreground: UIColor,
    aligment: NSTextAlignment,
    sketchLineHeight: CGFloat,
    fontSize: CGFloat
  ) -> NSAttributedString {
    let font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = aligment
    paragraphStyle.lineSpacing = font.lineSpacing(sketchLineHeight: sketchLineHeight)
    let attributes = [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.paragraphStyle: paragraphStyle,
      NSAttributedString.Key.foregroundColor: foreground
    ]
    return NSAttributedString(string: self, attributes: attributes)
  }

}
