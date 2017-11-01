//
//  ApproveButtonFooter.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 05/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Footer with one button: Approve. Class is used in PreferenceController
class ApproveButtonFooter: UIView {
    
    // MARK: - Properties
    
    var approveButton: UIButton!
    
    // MARK: - Initializers
    
    init(withColor color: UIColor) {
        
        let footerHeight = Constant.components.footer.height
        
        super.init(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: footerHeight))
        
        // Approve button
        approveButton = UIButton(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: footerHeight))
        let checkmark = UIImage(named: "checkmarkBlue")?.withRenderingMode(.alwaysTemplate)
        approveButton.setImage(checkmark, for: .normal)
        approveButton.tintColor = color
        addSubview(approveButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.UI.width, height: Constant.components.footer.height)
    }
}

