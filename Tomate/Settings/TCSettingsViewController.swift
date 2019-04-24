//
//  SettingsViewController.swift
//  Tomate
//
//  Created by dasdom on 02.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit

//let kNumberOfWorkPeriodsKey = "kNumberOfWorkPeriodsKey"

final class TCSettingsViewController: UIViewController {
  
  var settingsView: TCSettingsView {return view as! TCSettingsView}
  var workTimes = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 115, 120]
  var breakTimes = [1, 2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
  
  fileprivate var currentWorkDurationInMinutes = UserDefaults.standard.integer(forKey: TCTimerType.Work.rawValue) / 60
  fileprivate var currentBreakDurationInMinutes = UserDefaults.standard.integer(forKey: TCTimerType.Break.rawValue) / 60
  
  override func loadView() {
    view = TCSettingsView(frame: CGRect.zero)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    settingsView.pickerOfView.dataSource = self
    settingsView.pickerOfView.delegate = self
    let workGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TCSettingsViewController.moveMarker(sender:)))
    settingsView.workAndInputHostView.addGestureRecognizer(workGestureRecognizer)
    
    let breakGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TCSettingsViewController.moveMarker(sender:)))
    settingsView.breakAndInputHostView.addGestureRecognizer(breakGestureRecognizer)
    
    title = "设定"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let views = ["topLayoutGuide" : topLayoutGuide, "workInputHostView" : settingsView.workAndInputHostView] as [String: AnyObject]
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-10-[workInputHostView]", options: [], metrics: nil, views: views))
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(TCSettingsViewController.dismissSettings))
    navigationItem.rightBarButtonItem = doneButton
    
    settingsView.setWorkDurationTimeString("\(currentWorkDurationInMinutes) 分钟")
    settingsView.setBreakDurationString("\(currentBreakDurationInMinutes) 分钟")
    
    var row = 0
    for (index, minutes) in workTimes.enumerated() {
      if minutes == currentWorkDurationInMinutes {
        row = index
        break
      }
    }
    settingsView.pickerOfView.selectRow(row, inComponent: 0, animated: false)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    settingsView.moveMarker(toView: settingsView.workAndInputHostView)
  }
  
  @objc func dismissSettings() {
    dismiss(animated: true, completion: nil)
  }
  
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension TCSettingsViewController : UIPickerViewDelegate, UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch settingsView.selectedInTimerType {
    case .Work:
      return workTimes.count
    default:
      return breakTimes.count
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var minutes = 0
    switch settingsView.selectedInTimerType {
    case .Work:
      minutes = workTimes[row]
    default:
      minutes = breakTimes[row]
    }
    let attributedTitle = NSAttributedString(string: "\(minutes) 分钟", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white]))
    return attributedTitle
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var minutes = 0
    switch settingsView.selectedInTimerType {
    case .Work:
      minutes = workTimes[row]
      currentWorkDurationInMinutes = minutes
    default:
      minutes = breakTimes[row]
      currentBreakDurationInMinutes = minutes
    }
    
    let timerType = settingsView.setDurationString("\(minutes) 分钟")
    let seconds = minutes*60+1
    UserDefaults.standard.set(seconds, forKey: timerType.rawValue)
    UserDefaults.standard.synchronize()
  }
  
  @objc func moveMarker(sender: UITapGestureRecognizer) {
    settingsView.moveMarker(toView: sender.view!)
    settingsView.pickerOfView.reloadAllComponents()
    
    var times: [Int]
    var currentDuration: Int
    switch settingsView.selectedInTimerType {
    case .Work:
      times = workTimes
      currentDuration = currentWorkDurationInMinutes
    default:
      times = breakTimes
      currentDuration = currentBreakDurationInMinutes
    }
    
    var row = 0
    for (index, minutes) in times.enumerated() {
      if minutes == currentDuration {
        row = index
        break
      }
    }
    settingsView.pickerOfView.selectRow(row, inComponent: 0, animated: false)
  }
  
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
