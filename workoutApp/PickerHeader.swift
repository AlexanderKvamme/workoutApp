//
//  PickerHeader.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// A convenience class for making TwoLabelStacks with bigger typography, such as in PreferenceController header or the picker classes (Musclepicker, exercisepicker .etc)
class PickerHeader: TwoLabelStack {
    
    // MARK: - Initializer
    
    init(text: String) {
        
        let defaultFrame = CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100)
        
        super.init(frame: defaultFrame, topText: text, topFont: UIFont.custom(style: .bold, ofSize: .big), topColor: .akDark, bottomText: "", bottomFont: UIFont.custom(style: .bold, ofSize: .medium), bottomColor: .akDark, fadedBottomLabel: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func setTopColor(_ color: UIColor) {
        topLabel.textColor = color
    }
}

