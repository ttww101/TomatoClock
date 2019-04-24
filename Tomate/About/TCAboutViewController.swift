//
//  AboutViewController.swift
//  Tomate
//
//  Created by dasdom on 15.07.15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import UIKit
import SafariServices

final class TCAboutViewController: UIViewController {

  private var aboutAppView: TCAboutView {
    return view as! TCAboutView
  }
  
  override func loadView() {
    let contentView = TCAboutView(frame: .zero)
    
    title = NSLocalizedString("关于", comment: "About")
//    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: TimerStyleKit.timerColor]
    
    view = contentView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    aboutAppView.stackToView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20).isActive = true
    
    let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(TCAboutViewController.dismissToAbout))
    navigationItem.rightBarButtonItem = doneButton
  }
  
  @objc func dismissToAbout() {
    dismiss(animated: true, completion: nil)
  }
}
