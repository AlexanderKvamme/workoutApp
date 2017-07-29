//
//  ReusableComponents.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 29/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

final class ReusableComponents {
    
    static func makePlusButton() -> UIButton {
        
        let img = UIImage(named: "newButton")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        button.tintColor = UIColor.faded
        button.alpha = Constant.alpha.faded
        button.setImage(img, for: .normal)
        
        return button
    }
}
