//
//  SelectionViewButtonStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 13/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class SelectionViewButtonStack: UIStackView {
    
    let stack = UIStackView()
    
    init(withButtons buttons: [SelectionViewButton]) {
        
        super.init(frame: CGRect.zero)
        
        for button in buttons {
            stack.addArrangedSubview(button)
        }
        
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = Constant.Layout.SelectionVC.Stack.spacing
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

