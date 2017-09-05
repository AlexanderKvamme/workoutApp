//
//  PickerLabelStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit


/// Stack of a topLabel and a bottomlabel, with a button
class PickerLabelStack: TwoLabelStack {
    
    // MARK: - Initializers
    
    init(topText: String, bottomText: String) {
        
        let darkHeaderFont = UIFont.custom(style: .bold, ofSize: .medium)
        let darkSubHeaderFont = UIFont.custom(style: .medium, ofSize: .medium)
        
        super.init(frame: .zero, topText: topText, topFont: darkHeaderFont, topColor: .dark, bottomText: bottomText, bottomFont: darkSubHeaderFont, bottomColor: .dark, fadedBottomLabel: false)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.UI.width/2, height: Constant.components.PickerLabelStack.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

