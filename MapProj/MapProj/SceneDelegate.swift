//
//  SceneDelegate.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 23.04.2022.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  let disposeBag = DisposeBag()
  var window: UIWindow?
  var coordinator = FlowCoordinator()

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    window?.windowScene = windowScene
    window?.rootViewController = UINavigationController()
    guard let navigation = window?.rootViewController as? UINavigationController else { return }
    
    let flow = AuthorisationFlow(navigationController: navigation)
    coordinator.coordinate(flow: flow, with: OneStepper(withSingleStep: AppStep.authorisationRequired))
    
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    guard let windowScene = (scene as? UIWindowScene),
          let rootViewController = windowScene.keyWindow?.rootViewController
    else { return }

    hideBlurView(rootViewController)
  }

  func sceneWillResignActive(_ scene: UIScene) {
    guard let windowScene = (scene as? UIWindowScene),
          let rootViewController = windowScene.keyWindow?.rootViewController
    else { return }

    showBlurView(rootViewController)
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }

  func showBlurView(_ rootViewController: UIViewController) {
    let blurEffect = UIBlurEffect(style: .light)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
    rootViewController.view.addSubview(blurEffectView)
  }
  
  func hideBlurView(_ rootViewController: UIViewController) {
    rootViewController.view.subviews.forEach { subview in
      if subview is UIVisualEffectView {
        subview.removeFromSuperview()
      }
    }
  }
}

