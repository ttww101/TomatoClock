//
//  AboutView.swift
//  Tomate
//
//  Created by dasdom on 15.07.15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import UIKit

final class TCAboutView: UIView {
  
  let twitterToButton: UIButton
  let githubToButton: UIButton
  let rateToButton: UIButton
  let stackToView: UIStackView
  
  override init(frame: CGRect) {
    
    let avatarWidth = CGFloat(120)
    
    let avatarImageView = UIImageView(image: UIImage(named: "avatar"))
    avatarImageView.layer.cornerRadius = avatarWidth/2.0
    avatarImageView.clipsToBounds = true
    
    let handleLabel = UILabel(frame: .zero)
    handleLabel.text = "效率蕃茄鐘"
    handleLabel.textColor = TCTimerStyleKit.timerColor
    
    let buttonWithTitle = { (title: String) -> UIButton in
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.layer.borderWidth = 1
      button.layer.borderColor = UIColor.white.cgColor
      button.layer.cornerRadius = 5
      button.widthAnchor.constraint(equalToConstant: 120).isActive = true
      return button
    }
    
    twitterToButton = buttonWithTitle("Twitter")
    githubToButton = buttonWithTitle("Github")
    rateToButton = buttonWithTitle("Rate me")
    
    stackToView = UIStackView(arrangedSubviews: [avatarImageView, handleLabel])
    stackToView.translatesAutoresizingMaskIntoConstraints = false
    stackToView.axis = .vertical
    stackToView.alignment = .center
    stackToView.spacing = 10
    
    super.init(frame: frame)
    
    tintColor = .white
    backgroundColor = TCTimerStyleKit.backgroundColor
    
    addSubview(stackToView)
    
    var layoutConstraints = [NSLayoutConstraint]()
    layoutConstraints.append(stackToView.centerXAnchor.constraint(equalTo: centerXAnchor))
    layoutConstraints.append(avatarImageView.widthAnchor.constraint(equalToConstant: avatarWidth))
    layoutConstraints.append(avatarImageView.heightAnchor.constraint(equalToConstant: avatarWidth))
    NSLayoutConstraint.activate(layoutConstraints)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
