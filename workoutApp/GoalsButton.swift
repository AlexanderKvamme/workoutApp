//
//  GoalsButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 10/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


/// Subclass of UIButton to make label and the frame of the button equal
class GoalsButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        return self.titleLabel!.intrinsicContentSize
    }
    
    // Whever the button is changed or needs to layout subviews,
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}

