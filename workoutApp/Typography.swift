//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 02/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Typographic extension in UILabel

extension UILabel {
    
    func setSubTextColor(pSubString : String, pColor : UIColor){
        let attributedString: NSMutableAttributedString = self.attributedText != nil ? NSMutableAttributedString(attributedString: self.attributedText!) : NSMutableAttributedString(string: self.text!);
        
        let range = attributedString.mutableString.range(of: pSubString, options:NSString.CompareOptions.caseInsensitive)
        if range.location != NSNotFound {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: pColor, range: range);
        }
        self.attributedText = attributedString
    }
    
    func applyCustomAttributes(_ spacing: Constant.Attributes.letterSpacing) {
        guard self.text != nil && self.text!.characters.count > 0 else {
            print("applyCustomAttributes failed")
            return
        }

        // FIXME: - Utilize the spacing values
        var spacingValue: CGFloat = 0
    
        switch spacing {
        case Constant.Attributes.letterSpacing.more:
            spacingValue = 2
        default:
            spacingValue = 0.7
        }
        
        let attributedString = NSMutableAttributedString(string: self.text!)
        
        attributedString.addAttribute(NSKernAttributeName,
                                      value: CGFloat(0.7),
                                      range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}
