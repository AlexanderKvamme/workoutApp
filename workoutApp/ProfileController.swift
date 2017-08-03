//
//  ProfileController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 03/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

final class ProfileController: UIViewController {
    
    // MARK: - Properties
    
    private var settingsButton = UIButton()
    private var scrollView = UIScrollView()
    private var header = UILabel()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .lightest
        
        setupSettingsButton()
        setupHeader()
        setupScrollView()
        addMessages(to: scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // MARK: - Setup Methods
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.backgroundColor = .dark
        view.addSubview(scrollView)
        
        let sideInsets: CGFloat = 10
        
        // Layout
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: sideInsets),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: sideInsets),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -sideInsets),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -sideInsets),
            ])
    }
    
    private func setupHeader() {
        header.text = "DASHBOARD"
        header.font = UIFont.custom(style: .bold, ofSize: .medium   )
        header.textColor = .dark
        header.textAlignment = .center
        header.sizeToFit()
        view.addSubview(header)
        
        // Layout
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.bottomAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 0),
            header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            header.rightAnchor.constraint(equalTo: settingsButton.rightAnchor, constant: 0),
            ])
    }
    
    private func setupSettingsButton() {
        settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        settingsButton.backgroundColor = .darkest
        view.addSubview(settingsButton)
        
        let topRightInsets: CGFloat = 10
        let buttonDiameter: CGFloat = 30
        
        // Layout
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topRightInsets),
            settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -topRightInsets),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonDiameter),
            settingsButton.heightAnchor.constraint(equalToConstant: buttonDiameter),
            ])
    }
    
    // MARK: - Business Logic
    
    private func addMessages(to scrollView: UIScrollView) {
        let messageBox = makeMessageBox(withMessage: "Remember to use your legs")
        scrollView.addSubview(messageBox)
    }
    
    private func makeMessageBox(withMessage message: String) -> UIView {
        let boxFactory = BoxFactory.makeFactory(type: .SuggestionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        let box = Box(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        
        return box
    }
}

