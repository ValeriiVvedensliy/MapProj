//
//  AppDelegate.swift
//  MapProj
//
//  Created by Valera Vvedenskiy on 23.04.2022.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GMSServices.provideAPIKey("AIzaSyC6_iYti5Jj8-0qRT1FyEL-IfS3FFgCzm4")

    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, error in
      guard granted else {
        print("Разрешение не получено")
        return
      }
      self.sendNotificatioRequest(
        content: self.makeNotificationContent(),
        trigger: self.makeIntervalNotificatioTrigger()
      )
    }

    return true
  }

  func makeNotificationContent() -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Maps"
    content.subtitle = "Hi dear"
    content.body = "New routs wait you"
    content.badge = 4

    return content
  }

  func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
    return UNTimeIntervalNotificationTrigger(
      timeInterval: 30,
      repeats: false
    )
  }

  func sendNotificatioRequest(
    content: UNNotificationContent,
    trigger: UNNotificationTrigger
  ) {
      let request = UNNotificationRequest(
        identifier: "alaram",
        content: content,
        trigger: trigger
      )
      let center = UNUserNotificationCenter.current()
      center.add(request) { error in
        if let error = error {
          print(error.localizedDescription)
        }
      }
    }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

