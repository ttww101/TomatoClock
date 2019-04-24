//
//  AppDelegate.swift
//  Tomate
//
//  Created by dasdom on 29.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
  var focusTimeViewController: TCFocusViewController?
  
  let kAlreadyStartedKey = "alreadyStarted"
  let kRegisterNotificationSettings = "kRegisterNotificationSettings"
  
  var timeSession: WCSession?
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    customizeMyAppearance()
    
    registerSafeDefaultUserDefaults()
        
    focusTimeViewController = TCFocusViewController(nibName: nil, bundle: nil)
    
    if (WCSession.isSupported()) {
      timeSession = WCSession.default
      timeSession?.delegate = self
      timeSession?.activate()
      focusTimeViewController?.session = timeSession
    }

    window!.rootViewController = focusTimeViewController
    window!.makeKeyAndVisible()
    
    // Override point for customization after application launch.
//    var shouldPerformAdditionalDelegateHandling = true
    
    // If a shortcut was launched, display its information and take the appropriate action
    if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
        
        _ = handleShortcut(shortcutItem.type)
        
        // This will block "performActionForShortcutItem:completionHandler" from being called.
//        shouldPerformAdditionalDelegateHandling = false
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    print("\(notificationSettings)")
  }
    
  func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
    
    print(identifier ?? "No action identifier")
    
    if let identifier = identifier {
      if identifier == "BREAK_ACTION" {
        focusTimeViewController!.startYourBreak(sender: nil)
      } else if identifier == "WORK_ACTION" {
        focusTimeViewController!.startYourWork(sender: nil)
      }
    }
    
    if (WCSession.isSupported()) {
      timeSession = WCSession.default
      timeSession?.delegate = self
      timeSession?.activate()
      focusTimeViewController?.session = timeSession
    }
    
    completionHandler()
  }
    
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    
    let handledShortCut = handleShortcut(shortcutItem.type)
    
    completionHandler(handledShortCut)
  }
    
  func handleShortcut(_ shortCut: String) -> Bool {
    guard let last = shortCut.components(separatedBy: ".").last else { return false }

    switch last {
    case "Work":
      self.focusTimeViewController?.startDicTimer(withType: .Work)
    case "Break":
      self.focusTimeViewController?.startDicTimer(withType: .Break)
    default:
      return false
    }
    return true
  }
  
  func customizeMyAppearance() {
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().barTintColor = TCTimerStyleKit.backgroundColor
    
    let titleAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): TCTimerStyleKit.timerColor]
    UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(titleAttributes)
  }
}

extension AppDelegate: WCSessionDelegate {
//  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//    print(applicationContext)
//    guard let actionString = applicationContext["action"] as? String else { return }
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//      switch actionString {
//      case "work":
//        self.focusViewController?.startTimerWithType(.Work)
//      case "break":
//        self.focusViewController?.startTimerWithType(.Break)
//      case "stop":
//        self.focusViewController?.startTimerWithType(.Idle)
//      default:
//        break
//      }
//    })
//  }
    
  //TODO: Apps must implement the session(_:activationDidCompleteWith:error:) method, supporting asynchronous activation. On iOS, you must also implement the sessionDidBecomeInactive(_:) and sessionDidDeactivate(_:) methods, supporting multiple Apple Watches.
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      //TODO
  }
  func sessionDidBecomeInactive(_ session: WCSession) {
      //TODO
  }
  func sessionDidDeactivate(_ session: WCSession) {
      //TODO
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print(message)
    guard let actionString = message["action"] as? String else { return }
    DispatchQueue.main.async {
      switch actionString {
      case "work":
        self.focusTimeViewController?.startDicTimer(withType: .Work)
      case "break":
        self.focusTimeViewController?.startDicTimer(withType: .Break)
      case "stop":
        self.focusTimeViewController?.startDicTimer(withType: .Idle)
      default:
        break
      }
    }
  }
}

extension AppDelegate {
  func registerSafeDefaultUserDefaults() {
    let defaultPreferences = [kRegisterNotificationSettings : true, TCTimerType.Work.rawValue : 1501, TCTimerType.Break.rawValue : 301, TCTimerType.Procrastination.rawValue: 601] as [String:Any]
    UserDefaults.standard.register(defaults: defaultPreferences)
    UserDefaults.standard.synchronize()
    
    if UserDefaults.standard.bool(forKey: kRegisterNotificationSettings) {
      let restAction = UIMutableUserNotificationAction()
      restAction.identifier = "BREAK_ACTION"
      restAction.title = "Start Break"
      restAction.activationMode = .background
      
      let workAction = UIMutableUserNotificationAction()
      workAction.identifier = "WORK_ACTION"
      workAction.title = "Start Work"
      workAction.activationMode = .background
      
      let category = UIMutableUserNotificationCategory()
      category.setActions([workAction, restAction], for: .default)
      category.identifier = "START_CATEGORY"
      
      let categories = Set([category])
      //      let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: NSSet(object: category) as Set<NSObject>)
      let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
      UIApplication.shared.registerUserNotificationSettings(notificationSettings)
      
      UserDefaults.standard.set(false, forKey: kRegisterNotificationSettings)
      UserDefaults.standard.synchronize()
    }
  }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
