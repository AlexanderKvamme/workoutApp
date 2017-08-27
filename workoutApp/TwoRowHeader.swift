//
//  HeaderLabelStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 22/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class TwoRowHeader: TwoLabelStack {
    // MARK: - Properties
    
    // MARK: - Initializers
    
    init(topText: String, bottomText: String) {
        
        let defaultFrame = CGRect(x: 0, y: 0, width: Constant.UI.width, height: 100)
        
        super.init(frame: defaultFrame,
                   topText: topText,
                   topFont: UIFont.custom(style: .bold, ofSize: .medium),
                   topColor: UIColor.medium,
                   bottomText: bottomText,
                   bottomFont: UIFont.custom(style: .bold, ofSize: .big),
                   bottomColor: UIColor.darkest,
                   fadedBottomLabel: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    // MARK: - Methods
    
    override var intrinsicContentSize: CGSize {
        print("intrinsicContentSize")
        return CGSize(width: Constant.UI.width, height: 100)
    }
}
