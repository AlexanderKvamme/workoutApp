//
//  DeletionBox.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: Class

/// Red little box to indicate deletion of exercises .etc
class DeletionBox: Box {
    
    // MARK: - Initializers
    
    init(withText text: String) {
        let boxFactory = BoxFactory.makeFactory(type: .DeletionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        super.init(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        setupBoxFrameUsingAutolayout()
        
        boxContent?.messageLabel?.text = "DELETE"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setupBoxFrameUsingAutolayout() {
        // check if the frame supports autolayout ( only warning box does int he first place), and if so, set i up real nice.
        let contentInsets: CGFloat = 10
        
        guard let content = content else {
            preconditionFailure("No content")
        }
        
        // setup boxFrame
        if boxFrame.usesAutoLayout {
            boxFrame.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                boxFrame.leftAnchor.constraint(equalTo: leftAnchor),
                boxFrame.topAnchor.constraint(equalTo: topAnchor),
                boxFrame.widthAnchor.constraint(equalToConstant: Constant.UI.width/2),
                boxFrame.heightAnchor.constraint(greaterThanOrEqualToConstant: 10),       
                ])
        }
        
        // Setup ContentBox
        if content.usesAutoLayout {
            content.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                content.leftAnchor.constraint(equalTo: boxFrame.shimmer.leftAnchor, constant: contentInsets),
                content.rightAnchor.constraint(equalTo: boxFrame.rightAnchor, constant: -contentInsets),
                content.topAnchor.constraint(equalTo: boxFrame.topAnchor, constant: contentInsets),
                boxFrame.shimmer.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: contentInsets),
                ])
            
            content.clipsToBounds = true
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: boxFrame.topAnchor),
            bottomAnchor.constraint(equalTo: boxFrame.bottomAnchor),
            leftAnchor.constraint(equalTo: boxFrame.leftAnchor),
            rightAnchor.constraint(equalTo: boxFrame.rightAnchor),
            ])
        
        // Setup button
        button = UIButton()
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: boxFrame.leftAnchor),
            button.rightAnchor.constraint(equalTo: boxFrame.rightAnchor),
            button.topAnchor.constraint(equalTo: boxFrame.topAnchor),
            button.bottomAnchor.constraint(equalTo: boxFrame.bottomAnchor),
            ])
    }
}

