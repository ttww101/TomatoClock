//
//  FocusViewController.swift
//  Tomate
//
//  Created by dasdom on 29.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import AudioToolbox
import WatchConnectivity
import UserNotifications

final class TCFocusViewController: UIViewController {
  
  fileprivate var focusView: TCFocusView! { return self.view as! TCFocusView }
  fileprivate var timer: Timer?
  fileprivate var endDate: Date?
  fileprivate var localNotification: UNNotificationRequest?
  fileprivate var currentType = TCTimerType.Idle
//  private var workPeriods = [NSDate]()
//  private var numberOfWorkPeriods = 10
  private var totalMinutes = 0
  
  private let kLastDurationKey = "kLastDurationKey"
  private let kLastEndDateKey = "kLastEndDateKey"
  
  var session: WCSession?

    //MARK: - view cycle
  override func loadView() {
    view = TCFocusView(frame: .zero)
  }
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    focusView.workTimeBtn.addTarget(self, action: #selector(TCFocusViewController.startYourWork(sender:)), for: .touchUpInside)
    focusView.breakTimeBtn.addTarget(self, action: #selector(TCFocusViewController.startYourBreak(sender:)),
        for: .touchUpInside)
    focusView.procrastinateBtn.addTarget(self, action: #selector(TCFocusViewController.startProcrastination(sender:)), for: .touchUpInside)
    focusView.settingsToBtn.addTarget(self, action: #selector(TCFocusViewController.showSettings), for: .touchUpInside)
    focusView.aboutToBtn.addTarget(self, action: #selector(TCFocusViewController.showAboutController), for: .touchUpInside)
    
//    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "showSettingsFromLongPross:")
//    focusView.addGestureRecognizer(longPressRecognizer)
  }
  
  override func viewDidLayoutSubviews() {
    let minSizeDimension = min(view.frame.size.width, view.frame.size.height)
    focusView.myTimerView.timeLabel.font = focusView.myTimerView.timeLabel.font.withSize((minSizeDimension-2*focusView.leftSidePadding)*0.9/3.0-10.0)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if timer == nil {
      focusView.setTimeDuration(0, maxValue: 1)
    }
    
    let duration = UserDefaults.standard.integer(forKey: TCTimerType.Work.rawValue)
    print("duration: \(duration)")
  }
  
  //MARK: - button actions
  @objc func startYourWork(sender: UIButton?) {
    print("startWork")
    guard currentType != .Work else { showAlert(); return }
    startDicTimer(withType: .Work)
  }
  
  @objc func startYourBreak(sender: UIButton?) {
    guard currentType != .Break else { showAlert(); return }
    startDicTimer(withType: .Break)
  }
  
  @objc func startProcrastination(sender: UIButton) {
    guard currentType != .Procrastination else { showAlert(); return }
    startDicTimer(withType: .Procrastination)
  }
  
  @objc func showSettings() {
    present(TCDHNavigationController(rootViewController: TCSettingsViewController()), animated: true, completion: nil)
  }
  
  func showSettingsFromLongPross(sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      showSettings()
    }
  }
  
  @objc func showAboutController() {
    present(TCDHNavigationController(rootViewController: TCAboutViewController()), animated: true, completion: nil)
  }
  
  func setUIMode(forTimerType timerType: TCTimerType) {
    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
      switch timerType {
      case .Work:
        self.setBtn(button: self.focusView.workTimeBtn, enabled: true)
        self.setBtn(button: self.focusView.breakTimeBtn, enabled: false)
        self.setBtn(button: self.focusView.procrastinateBtn, enabled: false)
      case .Break:
        self.setBtn(button: self.focusView.workTimeBtn, enabled: false)
        self.setBtn(button: self.focusView.breakTimeBtn, enabled: true)
        self.setBtn(button: self.focusView.procrastinateBtn, enabled: false)
      case .Procrastination:
        self.setBtn(button: self.focusView.workTimeBtn, enabled: false)
        self.setBtn(button: self.focusView.breakTimeBtn, enabled: false)
        self.setBtn(button: self.focusView.procrastinateBtn, enabled: true)
      default:
        self.setBtn(button: self.focusView.workTimeBtn, enabled: true)
        self.setBtn(button: self.focusView.breakTimeBtn, enabled: true)
        self.setBtn(button: self.focusView.procrastinateBtn, enabled: true)
      }
      
      }, completion: nil)
  }
  
  func setBtn(button: UIButton, enabled: Bool) {
    if enabled {
      button.isEnabled = true
      button.alpha = 1.0
    } else {
      button.isEnabled = false
      button.alpha = 0.3
    }
  }
  
}

//MARK: - timer methods
extension TCFocusViewController {
  
  func startDicTimer(withType timerType: TCTimerType) {
    
    focusView.setTimeDuration(0, maxValue: 1)
    var typeName: String
    switch timerType {
    case .Work:
      typeName = "Work"
      currentType = .Work
//      workPeriods.append(NSDate())
    case .Break:
      typeName = "Break"
      currentType = .Break
    case .Procrastination:
      typeName = "Procrastination"
      currentType = .Procrastination
    default:
      typeName = "None"
      currentType = .Idle
      resetTimer()
//      focusView.numberOfWorkPeriodsLabel.text = "\(workPeriods.count)/\(numberOfWorkPeriods)"
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
      return
    }
    setUIMode(forTimerType: currentType)
    
//    focusView.numberOfWorkPeriodsLabel.text = "\(workPeriods.count)/\(numberOfWorkPeriods)"
    
    let seconds = UserDefaults.standard.integer(forKey: timerType.rawValue)
    endDate = Date(timeIntervalSinceNow: Double(seconds))
    
    let endTimeStamp = floor(endDate!.timeIntervalSince1970)
    
    if let sharedDefaults = UserDefaults(suiteName: "group.de.dasdom.Tomate") {
      sharedDefaults.set(endTimeStamp, forKey: "date")
      sharedDefaults.set(seconds, forKey: "maxValue")
      sharedDefaults.synchronize()
    }
    
    if let session = session, session.isPaired && session.isWatchAppInstalled {
      do {
        try session.updateApplicationContext(["date": endTimeStamp, "maxValue": seconds])
      } catch {
        print("Error!")
      }
//      if session.complicationEnabled {
        session.transferCurrentComplicationUserInfo(["date": endTimeStamp, "maxValue": seconds])
//      }
    }
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TCFocusViewController.updateTimeLabel(sender:)), userInfo: ["timerType" : seconds], repeats: true)
    
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    
    let notificationContent = UNMutableNotificationContent()
    notificationContent.body = "Time for \(typeName) is up!"
    notificationContent.sound = UNNotificationSound.default
    notificationContent.categoryIdentifier = "START_CATEGORY"
    
    localNotification = UNNotificationRequest(identifier: "TimeIsUp", content: notificationContent, trigger: nil)
    
//    localNotification!.fireDate = endDate
//    localNotification!.alertBody = "Time for " + typeName + " is up!";
//    localNotification!.soundName = UILocalNotificationDefaultSoundName
//    localNotification!.category = "START_CATEGORY"
//    UIApplication.shared.scheduleLocalNotification(localNotification!)

    if let notification = localNotification {
        UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
    }
    
  }
  
  @objc func updateTimeLabel(sender: Timer) {
    
    var totalNumberOfSeconds: CGFloat
    if let type = (sender.userInfo as! NSDictionary!)["timerType"] as? Int {
      totalNumberOfSeconds = CGFloat(type)
    } else {
      assert(false, "This should not happen")
      totalNumberOfSeconds = -1.0
    }
    
    let timeInterval = CGFloat(endDate!.timeIntervalSinceNow)
    if timeInterval < 0 {
      resetTimer()
      if timeInterval > -1 {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
      }
      focusView.setTimeDuration(0, maxValue: 1)
      return
    }
    
    focusView.setTimeDuration(timeInterval, maxValue: totalNumberOfSeconds)
  }
  
  private func resetTimer() {
    timer?.invalidate()
    timer = nil
    
    currentType = .Idle
    setUIMode(forTimerType: .Idle)
    
    if let session = session, session.isPaired && session.isWatchAppInstalled {
      do {
        try session.updateApplicationContext(["date": -1.0, "maxValue": -1.0])
      } catch {
        print("Error!")
      }
      session.transferCurrentComplicationUserInfo(["date": -1.0, "maxValue": -1.0])
    }
    
    if let sharedDefaults = UserDefaults(suiteName: "group.de.dasdom.Tomate") {
      sharedDefaults.removeObject(forKey: "date")
      sharedDefaults.synchronize()
    }
  }
}

//extension FocusViewController: WCSessionDelegate {
//  func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
//    print(userInfo)
//    guard let actionString = userInfo["action"] as? String else { return }
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//      switch actionString {
//      case "work":
//        self.startTimerWithType(.Work)
//      case "break":
//        self.startTimerWithType(.Break)
//      case "stop":
//        self.startTimerWithType(.Idle)
//      default:
//        break
//      }
//    })
//  }
//  func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
//        print(applicationContext)
//        guard let actionString = applicationContext["action"] as? String else { return }
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//          switch actionString {
//          case "work":
//            self.startTimerWithType(.Work)
//          case "break":
//            self.startTimerWithType(.Break)
//          case "stop":
//            self.startTimerWithType(.Idle)
//          default:
//            break
//          }
//        })
//  }
//}

//MARK: - alert
private extension TCFocusViewController {
  
  func showAlert() {
    var alertMessage = NSLocalizedString("您确定要停止吗", comment: "first part of alert message")
    switch currentType {
    case .Work:
      alertMessage += NSLocalizedString("工作?", comment: "second part of alert message")
    case .Break:
      alertMessage += NSLocalizedString("休息?", comment: "second part of alert message")
    case .Procrastination:
      alertMessage += NSLocalizedString("推迟?", comment: "second part of alert message")
    default:
      break
    }
    let alertController = UIAlertController(title: "停止?", message: alertMessage, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { action in
      print("\(action)")
    })
    alertController.addAction(cancelAction)
    
    let stopAction = UIAlertAction(title: "停止", style: .default, handler: { action in
      print("\(action)")
//      if self.currentType == .Work || self.workPeriods.count > 0 {
//        self.workPeriods.removeLast()
//      }
      self.startDicTimer(withType: .Idle)
    })
    alertController.addAction(stopAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
}

