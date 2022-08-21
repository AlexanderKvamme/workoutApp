//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 07/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

final class ExerciseTableFooter: UIView {
    
    let saveButton: UIButton!
    
    override init(frame: CGRect) {
        saveButton = UIButton(frame: frame)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.titleLabel?.font = UIFont.custom(style: .medium, ofSize: .bigger)
        saveButton.titleLabel?.applyCustomAttributes(Constant.Attributes.letterSpacing.medium)
        saveButton.setTitleColor(.light, for: .normal)
        saveButton.titleLabel?.textColor = .purple
        
        super.init(frame: frame)
        
        addSubview(saveButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
