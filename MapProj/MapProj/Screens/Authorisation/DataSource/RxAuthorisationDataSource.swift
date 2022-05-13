import Foundation
import UIKit
import RxDataSources
import Reusable

class RxAuthorisationDataSource: RxTableViewSectionedReloadDataSource<AuthorisationSectionModel> {
  init() {
    super.init { _, tableView, indexPath, item in
      switch indexPath.row {
      case 0:
        return RxAuthorisationDataSource.getTitleCell(item: item, tableView: tableView, indexPath: indexPath)

      case 1...2:
        return RxAuthorisationDataSource.getTextCell(item: item, tableView: tableView, indexPath: indexPath)

      case 3:
        return RxAuthorisationDataSource.getButtonCell(item: item, tableView: tableView, indexPath: indexPath)
        
      case 4:
        return RxAuthorisationDataSource.getValidationResultCell(item: item, tableView: tableView, indexPath: indexPath)

      default:
        return UITableViewCell()
      }
    }
  }

  private static func getTitleCell(
    item: AuthorisationSectionModel.Item,
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UITableViewCell {
    guard let item = item as? TitleCellModel else { return UITableViewCell() }

    let titleCell = tableView.dequeueReusableCell(for: indexPath) as TitleTableViewCell

    titleCell.config(item: item)

    return titleCell
  }

  private static func getTextCell(
    item: AuthorisationSectionModel.Item,
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UITableViewCell {
    guard let item = item as? TextFieldCellModel else { return UITableViewCell() }

    let textCell = tableView.dequeueReusableCell(for: indexPath) as TextFieldTableViewCell
    textCell.config(item: item)

    return textCell
  }

  private static func getButtonCell(
    item: AuthorisationSectionModel.Item,
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UITableViewCell {
    guard let item = item as? ButtonCellModel else { return UITableViewCell() }

    let buttonCell = tableView.dequeueReusableCell(for: indexPath) as ButtonTableViewCell

    buttonCell.config(item: item)

    return buttonCell
  }

  private static func getValidationResultCell(
    item: AuthorisationSectionModel.Item,
    tableView: UITableView,
    indexPath: IndexPath
  ) -> UITableViewCell {
    guard let item = item as? ValidationCellModel else { return UITableViewCell() }

    let validationCell = tableView.dequeueReusableCell(for: indexPath) as ValidationTableViewCell

    validationCell.config(item: item)

    return validationCell
  }
}
