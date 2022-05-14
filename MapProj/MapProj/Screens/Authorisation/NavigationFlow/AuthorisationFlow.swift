import Foundation
import RxFlow
import UIKit

class AuthorisationFlow: Flow {
  var navigationController: UINavigationController
  var root: Presentable {
    self.navigationController
  }

  init(
    navigationController: UINavigationController
  ) {
    self.navigationController = navigationController
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .authorisationRequired:
      return navigationToAuthorisationScreen()

    case .mapRequired:
      return navigationToMaps()
    }
  }

  private func navigationToAuthorisationScreen() -> FlowContributors {
    let viewModel = AuthorisationViewModel()

    let bundle = Bundle(for: AuthorisationTableViewController.self)
    let viewController = AuthorisationTableViewController(
      nibName: String(describing: AuthorisationTableViewController.self),
      bundle: bundle
    )
    viewController.viewModel = viewModel

    self.navigationController.pushViewController(viewController, animated: true)

    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewModel))
  }

  private func navigationToMaps() -> FlowContributors {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let viewController = storyboard.instantiateViewController(withIdentifier: "MapsViewController")
            as? MapsViewController else { return .none }
    
    viewController.modalTransitionStyle = .coverVertical
    viewController.modalPresentationStyle = .currentContext
  
    self.navigationController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController)
    )
  }
}


