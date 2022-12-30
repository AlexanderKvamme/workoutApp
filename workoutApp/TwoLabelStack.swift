//
//  twoStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - Class

/// Stack of a topLabel and a bottomlabel, with a button
class TwoLabelStack: UIView {
    
    // MARK: - Properties

    var topLabel: UILabel!
    var button: UIButton!
    var verticalStack = UIStackView()
    var bottomLabel: UILabel!
    
    // MARK: - Initializers
    
    init(frame: CGRect, topText: String, topFont: UIFont, topColor: UIColor, bottomText: String, bottomFont: UIFont, bottomColor: UIColor, fadedBottomLabel: Bool) {
        super.init(frame: frame)
        
        topLabel = UILabel()
        topLabel.text = topText.uppercased()
        topLabel.font = topFont
        topLabel.applyCustomAttributes(.medium)
        topLabel.textColor = topColor
        topLabel.sizeToFit()
        topLabel.isUserInteractionEnabled = false
        addSubview(topLabel)
        
        bottomLabel = UILabel()
        bottomLabel.text = bottomText.uppercased()
        bottomLabel.font = bottomFont
        bottomLabel.textColor = bottomColor
        bottomLabel.sizeToFit()
        bottomLabel.numberOfLines = 2
        bottomLabel.preferredMaxLayoutWidth = Constant.UI.width * 0.75
        bottomLabel.textAlignment = .center
        bottomLabel.isUserInteractionEnabled = false
        addSubview(bottomLabel)
        
        // Set alpha
        if fadedBottomLabel == true {
            bottomLabel.alpha = Constant.alpha.faded
        }
        
        // Set spacing
        if topLabel.hasCharacters {
            topLabel.applyCustomAttributes(.medium)
        }
        
        if bottomLabel.hasCharacters {
            bottomLabel.applyCustomAttributes(.medium)
        }
        
        // Hidden button
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        addSubview(button)
        bringSubviewToFront(button)
        
        setup()
        
        sizeToFit()
        isUserInteractionEnabled = true
        bottomLabel.isUserInteractionEnabled = false
        topLabel.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func setup(){
        setupStack()
    }
    
    private func setupStack() {
        verticalStack.distribution = .equalSpacing
        verticalStack.alignment = .center
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        verticalStack.isUserInteractionEnabled = false
        
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStack.addArrangedSubview(topLabel)
        verticalStack.addArrangedSubview(bottomLabel)
        
        addSubview(verticalStack)
        
        // Vertical stack cotaining top and bottom label
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        verticalStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        let marginGuide = layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            bottomLabel.leftAnchor.constraint(equalTo: marginGuide.leftAnchor),
            bottomLabel.rightAnchor.constraint(equalTo: marginGuide.rightAnchor)
            ])
        
        // Button
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leftAnchor.constraint(equalTo: leftAnchor),
            button.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        setNeedsLayout()
    }
    
    // MARK: public methods
    
    func setTopText(_ str: String) {
        topLabel.text = str
    }
    
    func setBottomText(_ str: String) {
        bottomLabel.text = str
    }
    
    func getBottomText() -> String {
        return bottomLabel.text ?? "NO TEXT"
    }
}

