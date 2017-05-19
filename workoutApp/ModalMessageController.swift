//
//  AlertView.swift
//  test
//
//  Created by Alexander Kvamme on 16/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class CustomAlertView: UIView, isModal {
    var backgroundView = UIView()
    var modalView = UIView()
    
    private let spaceFromSides: CGFloat = 20
    private let insetToComponents: CGFloat = 20
    private let spaceOverHeader: CGFloat = 20
    private let spaceOverContent: CGFloat = 5
    private let spaceOverCheckmark: CGFloat = 30
    
    convenience init(messageContent:String) {
        self.init(frame: UIScreen.main.bounds)
        
        setBackground()
        
        // Message View
        let ModalWidth = UIScreen.main.bounds.width - spaceFromSides
        
        // "Error" and errorNumber - Switch på CustomModalStyle... case "Message" eller "Error". Følgende er case Message
        
        // Message
        let messageLabel = UILabel()
        messageLabel.text = "Important Message".uppercased()
        messageLabel.textAlignment = .left
        messageLabel.font = UIFont.custom(style: .bold, ofSize: .medium)
        messageLabel.textColor = UIColor.medium
        modalView.addSubview(messageLabel)
        
        messageLabel.sizeToFit()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.topAnchor.constraint(equalTo: modalView.topAnchor, constant: insetToComponents).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: modalView.leftAnchor, constant: insetToComponents).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: messageLabel.frame.height).isActive = true
        messageLabel.widthAnchor.constraint(equalToConstant: messageLabel.frame.width).isActive = true
        
        // X
        let xView = UIImageView()
        xView.image = UIImage(named: "xmarkDarkBlue")
        xView.sizeToFit()
        
        modalView.addSubview(xView)
        xView.heightAnchor.constraint(equalToConstant: xView.frame.height).isActive = true
        xView.widthAnchor.constraint(equalToConstant: xView.frame.width).isActive = true
        xView.topAnchor.constraint(equalTo: modalView.topAnchor, constant: insetToComponents).isActive = true
        xView.rightAnchor.constraint(equalTo: modalView.rightAnchor, constant: -insetToComponents).isActive = true
        xView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header
        // - Make label
        // - Switch on customStyle... if message -> headerLabel.text = PSST!
        let headerLabel = UILabel()
        headerLabel.text = "PSST!"
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 1
        headerLabel.textColor = .dark
        headerLabel.font = UIFont.custom(style: .bold, ofSize: .bigger)
        headerLabel.sizeToFit()
        modalView.addSubview(headerLabel)
        headerLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor).isActive = true
        headerLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: spaceOverHeader).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: headerLabel.frame.height).isActive = true
        headerLabel.widthAnchor.constraint(equalToConstant: headerLabel.frame.width).isActive = true
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Content
        let contentLabel = UILabel(frame: CGRect(x: insetToComponents, y: 30, width: ModalWidth - 2*insetToComponents, height: 100))
        contentLabel.text = messageContent.uppercased()
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .dark
        contentLabel.font = UIFont.custom(style: .medium, ofSize: .medium)
        modalView.addSubview(contentLabel)
        
        // Add line spacing
        if let text = contentLabel.text {
            
            guard text.characters.count > 0 else { return }
            
            let attributedString = NSMutableAttributedString(string: contentLabel.text!)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(0.7), range: NSRange(location: 0, length: attributedString.length))
            contentLabel.attributedText = attributedString
        }
        
        contentLabel.sizeToFit()
        contentLabel.centerXAnchor.constraint(equalTo: modalView.centerXAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: spaceOverContent).isActive = true
        contentLabel.heightAnchor.constraint(equalToConstant: contentLabel.frame.height).isActive = true
        contentLabel.widthAnchor.constraint(equalToConstant: contentLabel.frame.width).isActive = true
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // checkmark
        let checkmarkView = UIButton()
        checkmarkView.setImage(UIImage(named: "checkmarkBlue"), for: .normal)
        checkmarkView.sizeToFit()
        checkmarkView.addTarget(self, action: #selector(checkmarkButtonhandler), for: .touchUpInside)
        
        modalView.addSubview(checkmarkView)
        checkmarkView.heightAnchor.constraint(equalToConstant: checkmarkView.frame.height).isActive = true
        checkmarkView.widthAnchor.constraint(equalToConstant: checkmarkView.frame.width).isActive = true
        checkmarkView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: spaceOverCheckmark).isActive = true
        checkmarkView.centerXAnchor.constraint(equalTo: modalView.centerXAnchor, constant: 0).isActive = true
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        // Modal
        let dialogViewHeight = contentLabel.frame.height + 180
        modalView.frame.origin = CGPoint(x: 32, y: frame.height)
        modalView.frame.size = CGSize(width: frame.width - spaceFromSides, height: dialogViewHeight)
        modalView.backgroundColor = UIColor.lighter
        modalView.layoutIfNeeded()
        addSubview(modalView)
        
        // Dismissable by backgorund tap
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
    
    // helper
    private func setBackground() {
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.dark
        backgroundView.alpha = 0
        addSubview(backgroundView)
    }
    
    @objc private func checkmarkButtonhandler() {
        dismiss(animated: true)
    }
}
