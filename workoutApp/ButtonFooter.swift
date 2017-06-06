//
//  SelectionFooter.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 03/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

public class ButtonFooter: UIView {
    
    var approveButton: UIButton!
    var cancelButton: UIButton!
    
    let footerHeight: CGFloat = 65
    let buttonWidth: CGFloat = Constant.UI.width/2
    
    init(withColor color: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constant.UI.width, height: footerHeight))
        
        // Approve button
        approveButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: footerHeight))
        
        let checkmark = UIImage(named: "checkmarkBlue")?.withRenderingMode(.alwaysTemplate)
        approveButton.setImage(checkmark, for: .normal)
        approveButton.tintColor = color
        addSubview(approveButton)
        
        // Cancel button
        cancelButton = UIButton(frame: CGRect(x: approveButton.frame.maxX, y: 0, width: buttonWidth, height: footerHeight))
        let xmark = UIImage(named: "xmarkDarkBlue")?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(xmark, for: .normal)
        cancelButton.tintColor = color
        addSubview(cancelButton)
    }
    
    public func setDebugColors() {
        approveButton.backgroundColor = .purple
        cancelButton.backgroundColor = .yellow
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
