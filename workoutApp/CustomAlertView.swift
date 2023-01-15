//
//  AlertView.swift
//  test
//
//  Created by Alexander Kvamme on 16/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import AKKIT

let screenWidth = UIScreen.main.bounds.width


enum ModalType {
    case message
    case error
}


/// Modal to display errors and messages to user. For example the confirmation/congratulation message after each workout.
class CustomAlertView: UIViewController, isModal {
    
    var onDismiss: (() -> ())?
    func show(animated: Bool) {
        print("Would show")
    }
    
    func dismiss(animated: Bool) {
        onDismiss?()
    }
    
    var containerView: UIView = UIView()
    private var headerText: AKAnimatableTextView
    
    // MARK: - Properties
    
    var backgroundView = UIView()
    
    private let spaceFromSides: CGFloat = 20
    private let insetToComponents: CGFloat = 20
    private let spaceOverHeader: CGFloat = 20
    private let spaceOverContent: CGFloat = 5
    private let spaceOverCheckmark: CGFloat = 30
    
    // MARK: - Life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        animate()
    }
    
    // MARK: - Initializers
    
    init(title: String = "Title", messageContent: String) {
        headerText = AKAnimatableTextView(text: title)
        super.init(nibName: nil, bundle: nil)
        
        setBackground()
        containerView.addSubview(headerText)
        headerText.color = .white
        headerText.frame = CGRect(x: 0, y: 0, width: Screen.width, height: 48)
        headerText.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.width.equalTo(Screen.width)
            make.height.equalTo(80)
        }
        
        // Content
        let contentLabel = UILabel(frame: CGRect(x: insetToComponents, y: 30, width: screenWidth - 2*insetToComponents, height: 100))
        contentLabel.text = messageContent
        contentLabel.textAlignment = .center
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.akLight.withAlphaComponent(.opacity.barelyFaded.rawValue)
        contentLabel.font = UIFont.custom(style: .medium, ofSize: .medium)
        containerView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(headerText.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }

        // Add line spacing if theres any text
        if let text = contentLabel.text, text.count > 0 {
            let attributedString = NSMutableAttributedString(string: contentLabel.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(0.7), range: NSRange(location: 0, length: attributedString.length))
            contentLabel.attributedText = attributedString
        }
        
        // Checkmark
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = .black
        containerView.addSubview(buttonContainer)
        view.backgroundColor = .red
        
        let checkmarkView = UIButton()
        checkmarkView.setImage(UIImage.chevronLeft24.withTintColor(.akLight), for: .normal)
        checkmarkView.transform = CGAffineTransform(rotationAngle: -.pi/2)
        checkmarkView.sizeToFit()
        checkmarkView.accessibilityIdentifier = "approve-modal-button"
        // Dismiss on tap
        checkmarkView.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        let tr = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        containerView.addGestureRecognizer(tr)
        buttonContainer.addSubview(checkmarkView)
        buttonContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120)
        }
        checkmarkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(48)
        }
        
        // Modal
        containerView.frame = Screen.frame
        containerView.backgroundColor = .black
        view.addSubview(containerView)
        
        // Make dismissable by backgorund tap
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    @objc func animate() {
        headerText.animate(duration: 0.15) { imageView in
            imageView.frame.origin.y += 10
        } suppliedCompletion: { imageView in
            imageView.frame.origin.y -= 20
        }
    }
    
    @objc func dismissView(){
        dismiss(animated: true)
    }
    
    private func setBackground() {
        backgroundView.frame = CGRect(x: 0, y: 0, width: 0, height: UIScreen.main.bounds.height)
        backgroundView.backgroundColor = .black
        view.addSubview(backgroundView)
    }
}

