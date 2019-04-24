//
//  TimerView.swift
//  Tomate
//
//  Created by dasdom on 29.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import QuartzCore

final class TCFocusView: UIView {
  let myTimerView: TCTimerView
  let workTimeBtn: UIButton
  let breakTimeBtn: UIButton
  let procrastinateBtn: UIButton
//  let numberOfWorkPeriodsLabel: UILabel
  //    let stepper: UIStepper
  let settingsToBtn: UIButton
  let aboutToBtn: UIButton
  
  let leftSidePadding = CGFloat(10)
  
  override init(frame: CGRect) {
    myTimerView = TCTimerView(frame: CGRect.zero)
    myTimerView.translatesAutoresizingMaskIntoConstraints = false
    
    let makeButton = { (title: String) -> UIButton in
      let btn = UIButton(type: .system)
      btn.translatesAutoresizingMaskIntoConstraints = false
      btn.layer.cornerRadius = 40
      btn.layer.borderWidth = 1.0
      btn.layer.borderColor = UIColor.white.cgColor
      btn.setTitle(title, for: .normal)
      btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22)
      return btn
    }
    
//    numberOfWorkPeriodsLabel = {
//      let label = UILabel()
//      label.translatesAutoresizingMaskIntoConstraints = false
//      label.textAlignment = .Center
//      label.textColor = TimerStyleKit.timerColor
//      label.font = UIFont.systemFontOfSize(25)
//      label.text = "0/0"
//      label.hidden = true
//      return label
//      }()
    
    settingsToBtn = {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
//                  button.backgroundColor = UIColor.blueColor()
//      if let templateImage = UIImage(named: "settings")?.imageWithRenderingMode(.AlwaysTemplate) {
//        button.setImage(templateImage, forState: .Normal)
//      }
      button.setImage(TCTimerStyleKit.imageOfSettings, for: .normal)
      button.accessibilityLabel = NSLocalizedString("设定", comment: "")
      return button
      }()
    
    aboutToBtn = {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      //            button.backgroundColor = UIColor.blueColor()
//      if let templateImage = UIImage(named: "settings")?.imageWithRenderingMode(.AlwaysTemplate) {
//        button.setImage(templateImage, forState: .Normal)
//      }
      button.setImage(TCTimerStyleKit.imageOfInfo, for: .normal)
      button.accessibilityLabel = NSLocalizedString("关于", comment: "")
      return button
      }()
    
    workTimeBtn = makeButton("工作")
    breakTimeBtn = makeButton("休息")
    
    procrastinateBtn = makeButton("推迟")
    if let font = procrastinateBtn.titleLabel?.font {
      procrastinateBtn.titleLabel?.font = font.withSize(12)
    }
    
    super.init(frame: frame)
    
    backgroundColor = TCTimerStyleKit.backgroundColor
    tintColor = UIColor.white
    
    addSubview(myTimerView)
//    addSubview(numberOfWorkPeriodsLabel)
    //        addSubview(stepper)
    addSubview(workTimeBtn)
    addSubview(breakTimeBtn)
    //        addSubview(centerView)
    addSubview(procrastinateBtn)
    addSubview(settingsToBtn)
    addSubview(aboutToBtn)
    
    let views = ["aboutButton": aboutToBtn, "settingsButton" : settingsToBtn, "timerView" : myTimerView, "workButton" : workTimeBtn, "breakButton" : breakTimeBtn, "procrastinateButton" : procrastinateBtn] as [String:UIView]
//    let metrics = ["timerWidth": 400, "timerHeight": 400, "workWidth": 80, "settingsWidth": 44]
    let metrics = ["workWidth": 80, "settingsWidth": 44, "sidePadding": leftSidePadding]
    
    var constraints = [NSLayoutConstraint]()
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-13-[aboutButton]-(>=10)-[settingsButton(settingsWidth)]-13-|", options: .alignAllCenterY, metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[settingsButton(settingsWidth)]", options: [], metrics: metrics, views: views)
    
//    constraints.append(timerView.widthAnchor.constraintEqualToConstant(CGFloat(metrics["timerWidth"]!)))
    
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=sidePadding)-[timerView]-(>=sidePadding)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(==sidePadding@751)-[timerView]-(==sidePadding@751)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=sidePadding)-[timerView]-(>=sidePadding)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(==sidePadding@750)-[timerView]-(==sidePadding@750)-|", options: [], metrics: metrics, views: views)
    constraints.append(myTimerView.widthAnchor.constraint(equalTo: myTimerView.heightAnchor))
    
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[timerView]-40-[procrastinateButton(workWidth,breakButton,workButton)]", options: .alignAllCenterX, metrics: metrics, views: views)
    
    constraints.append(myTimerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50))
    
    constraints += NSLayoutConstraint.constraints(withVisualFormat: "[breakButton]-10-[procrastinateButton]-10-[workButton(workWidth,breakButton,procrastinateButton)]", options: [], metrics: metrics, views: views)

    constraints.append(workTimeBtn.centerYAnchor.constraint(equalTo: procrastinateBtn.centerYAnchor, constant: -20))
    constraints.append(breakTimeBtn.centerYAnchor.constraint(equalTo: workTimeBtn.centerYAnchor))

    constraints.append(procrastinateBtn.centerXAnchor.constraint(equalTo: centerXAnchor))
    
    NSLayoutConstraint.activate(constraints)
        
//    addConstraint(NSLayoutConstraint(item: numberOfWorkPeriodsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: timerView, attribute: .CenterY, multiplier: 1.0, constant: 70))
//    
//    addConstraint(NSLayoutConstraint(item: numberOfWorkPeriodsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: timerView, attribute: .CenterX, multiplier: 1.0, constant: 0))

//    timerView.timeLabel.font = timerView.timeLabel.font.fontWithSize((frame.size.width-2*CGFloat(metrics["sidePadding"]!))*0.9/3.0-10.0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setTimeDuration(_ duration: CGFloat, maxValue: CGFloat) {
    myTimerView.durationInSeconds = duration
    myTimerView.maxValue = maxValue
//    timerView.setNeedsDisplay()
    myTimerView.updateTimer()
  }
  
}
