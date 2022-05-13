import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator
import RxFlow
import Reusable

public final class AuthorisationTableViewController: UITableViewController {
  lazy var dataSource = RxAuthorisationDataSource()
  private let disposeBag = DisposeBag()
  public var viewModel: AuthorisationViewModel?

  override public func viewDidLoad() {
    super.viewDidLoad()

    registerNib()
    setUpView()
    setupBindings()
  }

  // MARK: - Bindings
  private func setupBindings() {
    viewModel?.output.source
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

  private func setUpView() {
    navigationController?.isNavigationBarHidden = true
    view.backgroundColor = Constants.viewBackgroundColor
    tableView.backgroundColor = Constants.tableViewBackgroundColor
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = Constants.tableViewEstimatedRowHeight
    tableView.keyboardDismissMode = .interactive
    tableView.dataSource = nil
    tableView.delegate = nil
  }

  private func registerNib() {
    tableView.register(cellType: TitleTableViewCell.self)
    tableView.register(cellType: TextFieldTableViewCell.self)
    tableView.register(cellType: ButtonTableViewCell.self)
    tableView.register(cellType: ValidationTableViewCell.self)
  }
}

private enum Constants {
  // Colors
  static let viewBackgroundColor = UIColor.Purple
  static let tableViewBackgroundColor = UIColor.Purple
  
  // Sizes
  static let tableViewEstimatedRowHeight: CGFloat = 48
}
