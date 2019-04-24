//
//  SettingsView.swift
//  Tomate
//
//  Created by dasdom on 02.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import QuartzCore

final class TCSettingsView: UIView {
  
  private let myMarkerView: UIView
  let workAndInputHostView: TCInputHostView
  let breakAndInputHostView: TCInputHostView
  private let workAndPeriodsLabel: UILabel
  private let workAndPeriodsStepper: UIStepper
  let pickerOfView: UIPickerView
  var selectedInTimerType: TCTimerType
  
  override init(frame: CGRect) {
    
    myMarkerView = {
      let view = UIView()
      view.layer.cornerRadius = 5
      return view
      }()
    
    let workPeriodsSettingsHostView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
      }()
    
    workAndPeriodsLabel = {
      let label = UILabel()
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
      }()
    workPeriodsSettingsHostView.addSubview(workAndPeriodsLabel)
    
    workAndPeriodsStepper = {
      let stepper = UIStepper()
      stepper.translatesAutoresizingMaskIntoConstraints = false
      return stepper
      }()
    workPeriodsSettingsHostView.addSubview(workAndPeriodsStepper)
    
    
    workAndInputHostView = TCInputHostView(frame: CGRect.zero)
    workAndInputHostView.timeNameLabel.text = NSLocalizedString("工作時間長", comment: "Settings name for the work duration")
    workAndInputHostView.tag = 0
    
    breakAndInputHostView = TCInputHostView(frame: CGRect.zero)
    breakAndInputHostView.timeNameLabel.text = NSLocalizedString("休息時間長", comment: "Settings name for the break duration")
    breakAndInputHostView.tag = 1
    
    pickerOfView = {
      let pickerView = UIPickerView()
      pickerView.translatesAutoresizingMaskIntoConstraints = false
      pickerView.showsSelectionIndicator = true
      return pickerView
      }()
    
    selectedInTimerType = TCTimerType.Work
    
    super.init(frame: frame)
    
    backgroundColor = TCTimerStyleKit.backgroundColor
    myMarkerView.backgroundColor = UIColor.white
    
    addSubview(myMarkerView)
    addSubview(workAndInputHostView)
    addSubview(breakAndInputHostView)
    addSubview(pickerOfView)
    
    let metrics = ["hostHeight" : 40, "hostViewGap" : 10]
    let views = ["markerView" : myMarkerView, "workHostView" : workAndInputHostView, "breakHostView" : breakAndInputHostView, "picker" : pickerOfView]
    var constraints = [NSLayoutConstraint]()
    
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-5-[workHostView]-5-|", options: [], metrics: nil, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[workHostView(hostHeight,breakHostView)]-hostViewGap-[breakHostView]", options: [.alignAllLeft, .alignAllRight], metrics: metrics, views: views)
    
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "|[picker]|", options: [], metrics: nil, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[breakHostView][picker]", options: [], metrics: nil, views: views)
    
    NSLayoutConstraint.activate(constraints)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setDurationString(_ string: String) -> TCTimerType {
    var timerType = TCTimerType.Idle
    if workAndInputHostView.frame.contains(myMarkerView.center) {
      setWorkDurationTimeString(string)
      timerType = TCTimerType.Work
    } else {
      setBreakDurationString(string)
      timerType = TCTimerType.Break
    }
    return timerType
  }
  
  func setWorkDurationTimeString(_ string: String) {
    workAndInputHostView.durationTimeLabel.text = string
  }
  
  func setBreakDurationString(_ string: String) {
    breakAndInputHostView.durationTimeLabel.text = string
  }
  
  func moveMarker(toView view: UIView) {
    if workAndInputHostView.frame.contains(view.center) {
      selectedInTimerType = .Work
    } else {
      selectedInTimerType = .Break
    }
    
    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5.0, options: [], animations: {
      self.myMarkerView.frame = view.frame.insetBy(dx: -3, dy: -3)
      }, completion: nil)
  }
  
  final class TCInputHostView: UIView {
    let timeNameLabel: UILabel
    let durationTimeLabel: UILabel
    
    override init(frame: CGRect) {
      let makeLabel = { () -> UILabel in
        let myLabel = UILabel()
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        myLabel.textColor = TCTimerStyleKit.timerColor
        myLabel.text = "-"
        return myLabel
      }
      
      timeNameLabel = makeLabel()
      durationTimeLabel = makeLabel()
      
      super.init(frame: frame)
      
      translatesAutoresizingMaskIntoConstraints = false
      backgroundColor = TCTimerStyleKit.backgroundColor
      layer.cornerRadius = 5
      
      addSubview(timeNameLabel)
      addSubview(durationTimeLabel)
      
      let views = ["nameLabel" : timeNameLabel, "durationLabel" : durationTimeLabel]
      var constraints = [NSLayoutConstraint]()
      
      constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[nameLabel]-(>=10)-[durationLabel]-|", options: .alignAllFirstBaseline, metrics: nil, views: views)
      constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel(durationLabel)]-|", options: .alignAllFirstBaseline, metrics: nil, views: views)
      
      NSLayoutConstraint.activate(constraints)
      
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}
