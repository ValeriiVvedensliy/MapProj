import Foundation
import UIKit

extension UIFont {
  func lineSpacing(sketchLineHeight: CGFloat) -> CGFloat {
    sketchLineHeight - lineHeight
  }
}
