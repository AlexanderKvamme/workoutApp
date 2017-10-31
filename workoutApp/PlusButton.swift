//
//  PlusButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 29/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

final class PlusButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let img = UIImage(named: "plusButton")?.withRenderingMode(.alwaysTemplate)
        accessibilityIdentifier = "plus-button"
        tintColor = UIColor.secondary
        alpha = Constant.alpha.faded
        setImage(img, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.components.plusButton.dimensions, height: Constant.components.plusButton.dimensions)
    }
}

