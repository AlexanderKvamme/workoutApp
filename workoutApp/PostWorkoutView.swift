//
//  FullscreenCustomAlertView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/12/2022.
//  Copyright © 2022 Alexander Kvamme. All rights reserved.
//

import UIKit

// Modal to display errors and messages to user. For example the confirmation/congratulation message after each workout.
class PostWorkoutView: UIView, isModal {
    
    // MARK: - Properties
    
    var backgroundView = UIView()
    var modalView = UIView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setBackground()
    }
    
    convenience init(type: ModalType, messageContent: String) {
        self.init(frame: UIScreen.main.bounds)
        
        // top right x mark
        let xView = UIButton()
        xView.tintColor = .akDark
        xView.setImage(UIImage.close24.withRenderingMode(.alwaysTemplate), for: .normal)
        xView.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        xView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        modalView.addSubview(xView)
        xView.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.top.right.equalToSuperview().inset(24)
        }
        
        // Header
        let headerLabel = UILabel()
        headerLabel.text = "Nice!"
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 1
        headerLabel.textColor = .akDark
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .bigger)
        headerLabel.sizeToFit()
        modalView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(modalView.snp.centerY)
            make.left.right.equalToSuperview()
        }
        
        // Content
        let contentLabel = UILabel()
        contentLabel.text = messageContent
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .akDark.withAlphaComponent(.opacity.fullyFaded.rawValue)
        contentLabel.font = UIFont.custom(style: .medium, ofSize: .medium)
        modalView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
        }
        
        // Add line spacing if theres any text
        if let text = contentLabel.text, text.count > 0 {
            let attributedString = NSMutableAttributedString(string: contentLabel.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.7), range: NSRange(location: 0, length: attributedString.length))
            contentLabel.attributedText = attributedString
        }
        
        // Checkmark container
        let container = UIButton()
        container.backgroundColor = .black
        container.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        modalView.addSubview(container)
        container.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        // Checkmark
        let checkmarkView = UIButton()
        checkmarkView.setImage(UIImage.checkmarkIcon.withTintColor(.akLight), for: .normal)
        checkmarkView.sizeToFit()
        checkmarkView.accessibilityIdentifier = "approve-modal-button"
        checkmarkView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        checkmarkView.isUserInteractionEnabled = false
        modalView.addSubview(checkmarkView)
        checkmarkView.snp.makeConstraints { make in
            make.center.equalTo(container)
        }
        
        // Modal
        let dialogViewHeight = UIScreen.main.bounds.height
        modalView.frame.origin = CGPoint(x: 32, y: frame.height)
        modalView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: dialogViewHeight)
        modalView.backgroundColor = UIColor.akLight
        modalView.layer.cornerRadius = 16
        modalView.layoutIfNeeded()
        
        addSubview(modalView)
        
        // Make dismissable by backgorund tap
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    @objc func dismissView(){
        dismiss(animated: true)
    }
    
    private func setBackground() {
        backgroundView.frame = frame
        backgroundView.backgroundColor = .black.withAlphaComponent(0.92)
        backgroundView.backgroundColor = .black.withAlphaComponent(0)
        addSubview(backgroundView)
    }
}

