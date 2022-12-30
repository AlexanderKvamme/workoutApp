//
//  AlertView.swift
//  test
//
//  Created by Alexander Kvamme on 16/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


enum ModalType {
    case message
    case error
}


/// Modal to display errors and messages to user. For example the confirmation/congratulation message after each workout.
class CustomAlertView: UIView, isModal {
    
    // MARK: - Properties
    
    var backgroundView = UIView()
    var modalView = UIView()
    
    private let spaceFromSides: CGFloat = 20
    private let insetToComponents: CGFloat = 20
    private let spaceOverHeader: CGFloat = 20
    private let spaceOverContent: CGFloat = 5
    private let spaceOverCheckmark: CGFloat = 30
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setBackground()
    }
    
    convenience init(type: ModalType, messageContent: String) {
        self.init(frame: UIScreen.main.bounds)
        
        let ModalWidth = UIScreen.main.bounds.width - spaceFromSides

        // Message
        let typeStack = UIStackView() // message or error
        var typeStackHeight: CGFloat = 0
        typeStack.axis = NSLayoutConstraint.Axis.vertical
        typeStack.distribution = UIStackView.Distribution.equalCentering
        typeStack.alignment = UIStackView.Alignment.top
        typeStack.spacing = 0
        modalView.addSubview(typeStack)
        
        // Set up the view based on type
        switch type {
        case .message:
            let messageLabel = UILabel()
            messageLabel.text = "Important Message"
            messageLabel.textAlignment = .left
            messageLabel.font = .custom(style: .bold, ofSize: .medium)
            messageLabel.textColor = .akDark.withAlphaComponent(.opacity.fullyFaded.rawValue)
            messageLabel.sizeToFit()
            typeStackHeight += messageLabel.frame.height
            modalView.addSubview(messageLabel)
            typeStack.addArrangedSubview(messageLabel)
        
        case .error:
            let errorNameLabel = UILabel()
            errorNameLabel.text = "Error".uppercased()
            errorNameLabel.textAlignment = .left
            errorNameLabel.font = .custom(style: .bold, ofSize: .smallPlus)
            errorNameLabel.textColor = .akDark.withAlphaComponent(.opacity.fullyFaded.rawValue)
            errorNameLabel.sizeToFit()
            modalView.addSubview(errorNameLabel)
            
            let errorNumberLabel = UILabel()
            errorNumberLabel.text = "42"
            errorNumberLabel.textAlignment = .center
            errorNumberLabel.font = UIFont.custom(style: .bold, ofSize: .smallPlus)
            errorNumberLabel.textColor = .akDark.withAlphaComponent(.opacity.fullyFaded.rawValue)
            errorNumberLabel.sizeToFit()
            modalView.addSubview(errorNumberLabel)
            
            typeStackHeight += errorNameLabel.frame.height
            typeStackHeight += errorNumberLabel.frame.height
            
            typeStack.addArrangedSubview(errorNameLabel)
            typeStack.addArrangedSubview(errorNumberLabel)
        }
        
        // Arrange stack
        typeStack.translatesAutoresizingMaskIntoConstraints = false
        typeStack.sizeToFit()
        typeStack.topAnchor.constraint(equalTo: modalView.topAnchor, constant: insetToComponents).isActive = true
        typeStack.leftAnchor.constraint(equalTo: modalView.leftAnchor, constant: insetToComponents).isActive = true
        typeStack.heightAnchor.constraint(equalToConstant: typeStackHeight).isActive = true
        typeStack.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        // top right x mark
        let xView = UIButton()
        xView.tintColor = .akDark
        xView.setImage(UIImage.close.withRenderingMode(.alwaysTemplate), for: .normal)
        xView.setImage(UIImage.close24.withRenderingMode(.alwaysTemplate), for: .normal)
        xView.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        xView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        modalView.addSubview(xView)
        xView.heightAnchor.constraint(equalToConstant: xView.frame.height).isActive = true
        xView.widthAnchor.constraint(equalToConstant: xView.frame.width).isActive = true
        xView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: insetToComponents).isActive = true
        xView.rightAnchor.constraint(equalTo: modalView.rightAnchor, constant: -insetToComponents).isActive = true
        xView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header
        let headerLabel = UILabel()
        headerLabel.text = "Hello"
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 1
        headerLabel.textColor = .akDark
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .bigger)
        headerLabel.sizeToFit()
        modalView.addSubview(headerLabel)
        headerLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor).isActive = true
        headerLabel.topAnchor.constraint(equalTo: xView.bottomAnchor, constant: spaceOverHeader).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: headerLabel.frame.height).isActive = true
        headerLabel.widthAnchor.constraint(equalToConstant: headerLabel.frame.width).isActive = true
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Content
        let contentLabel = UILabel(frame: CGRect(x: insetToComponents, y: 30, width: ModalWidth - 2*insetToComponents, height: 100))
        contentLabel.text = messageContent
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .akDark.withAlphaComponent(.opacity.fullyFaded.rawValue)
        contentLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        modalView.addSubview(contentLabel)
        
        // Add line spacing if theres any text
        if let text = contentLabel.text, text.count > 0 {
            let attributedString = NSMutableAttributedString(string: contentLabel.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.7), range: NSRange(location: 0, length: attributedString.length))
            contentLabel.attributedText = attributedString
        }
    
        contentLabel.sizeToFit()
        contentLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: spaceOverContent).isActive = true
        contentLabel.heightAnchor.constraint(equalToConstant: contentLabel.frame.height).isActive = true
        contentLabel.widthAnchor.constraint(equalToConstant: contentLabel.frame.width).isActive = true
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Checkmark
        let checkmarkView = UIButton()
        checkmarkView.setImage(UIImage.checkmarkIcon.withTintColor(.akDark), for: .normal)
        checkmarkView.sizeToFit()
        checkmarkView.accessibilityIdentifier = "approve-modal-button"
        checkmarkView.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        modalView.addSubview(checkmarkView)
        
        checkmarkView.heightAnchor.constraint(equalToConstant: checkmarkView.frame.height).isActive = true
        checkmarkView.widthAnchor.constraint(equalToConstant: checkmarkView.frame.width).isActive = true
        checkmarkView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: spaceOverCheckmark).isActive = true
        checkmarkView.centerXAnchor.constraint(equalTo: modalView.centerXAnchor, constant: 0).isActive = true
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        // Modal
        let dialogViewHeight = contentLabel.frame.height + 210
        modalView.frame.origin = CGPoint(x: 32, y: frame.height)
        modalView.frame.size = CGSize(width: frame.width - spaceFromSides, height: dialogViewHeight)
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
        addSubview(backgroundView)
    }
}

