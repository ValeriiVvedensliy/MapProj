import UIKit
import RxSwift
import Reusable

class TitleTableViewCell: RxTableViewCell<TitleCellModel>, NibReusable {
  @IBOutlet private var titleLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
      setUpCell()
    }

  override func config(item: TitleCellModel) {
    titleLabel.text = item.title.localizationString
  }
  
  private func setUpCell() {
    contentView.backgroundColor = Constants.contentViewBackgroundColor
    titleLabel.textColor = Constants.lblTitleForegroundColor
  }
}

private enum Constants {
  // Colors
  static let lblTitleForegroundColor = UIColor.White
  static let contentViewBackgroundColor = UIColor.Purple
}
