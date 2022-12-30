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
    
    /// Spaces out a labels text, if it contains any characters to space out.
    func applyCustomAttributes(_ spacing: Constant.Attributes.letterSpacing) {
        guard self.hasCharacters else {
            print("applyCustomAttributes failed on \(self)")
            return
        }

        // Set spacing values
        let spacingValue: CGFloat = spacing == Constant.Attributes.letterSpacing.more ? 2 : 0.7
        
        // Apply spacing
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacingValue, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}

