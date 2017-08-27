//
//  PickerLabelStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

// MARK: - Class

/// Stack of a topLabel and a bottomlabel, with a button
class PickerLabelStack: TwoLabelStack {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    init(topText: String, bottomText: String) {
        
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        super.init(frame: .zero, topText: topText, topFont: darkHeaderFont, topColor: .dark, bottomText: bottomText, bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
    }
    
    /*
    init(frame: CGRect, topText: String, topFont: UIFont, topColor: UIColor, bottomText: String, bottomFont: UIFont, bottomColor: UIColor, fadedBottomLabel: Bool) {
        super.init(frame: frame)
        
        topLabel = UILabel()
        topLabel.text = topText.uppercased()
        topLabel.applyCustomAttributes(.medium)
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
        bottomLabel.applyCustomAttributes(.medium)
        bottomLabel.sizeToFit()
        bottomLabel.numberOfLines = 2
        bottomLabel.preferredMaxLayoutWidth = Constant.UI.width * 0.75
        bottomLabel.textAlignment = .center
        bottomLabel.isUserInteractionEnabled = false
        addSubview(bottomLabel)
        
        if fadedBottomLabel == true {
            bottomLabel.alpha = Constant.alpha.faded
        }
        
        // Hidden button
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        addSubview(button)
        bringSubview(toFront: button)
        
        setup()
        
        sizeToFit()
        isUserInteractionEnabled = true
        bottomLabel.isUserInteractionEnabled = false
        topLabel.isUserInteractionEnabled = false
    }*/
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.UI.width/2, height: Constant.components.PickerLabelStack.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    
}

