//
//  AttributedText.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 10/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Bullet point generator

extension GoalsController {
    
    /// Returns one list item
    static func bulletedListItem(string: String) -> NSAttributedString {
        
        // Properties
        let font = UIFont.custom(style: .medium, ofSize: .medium)
        let bulletColor = UIColor.akDark
        let textColor = UIColor.akDark
        let bulletSize: CGFloat = font.pointSize
        
        // Setup
        let textAttributesDictionary = [NSAttributedStringKey.font : font,
                                        NSAttributedStringKey.foregroundColor:textColor]
        let bulletAttributesDictionary = [NSAttributedStringKey.font : font.withSize(bulletSize),
                                          NSAttributedStringKey.foregroundColor:bulletColor]
        let fullAttributedString = NSMutableAttributedString.init()
        
//        let bulletPoint: String = "\u{2022}"
        let bulletPoint: String = ""
//        let formattedString: String = "\(bulletPoint) \(string)"
        let formattedString: String = "\(bulletPoint)\(string)"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
        let paragraphStyle = createParagraphAttribute()
        
        attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle],
                                       range: NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(textAttributesDictionary, range: NSMakeRange(0, attributedString.length))
        
        let string: NSString = NSString(string: formattedString)
        let rangeForBullet: NSRange = string.range(of: bulletPoint)
        
        attributedString.addAttributes(bulletAttributesDictionary, range: rangeForBullet)
        fullAttributedString.append(attributedString)
        
        return fullAttributedString
    }
    
    static func bulletedList(strings:[String]) -> NSAttributedString {
        
        // Properties
        
        let font = UIFont.custom(style: .medium, ofSize: .medium)
        let bulletColor = UIColor.akDark
        let textColor = UIColor.akDark
        let bulletSize: CGFloat = font.pointSize
        
        // Setup
        
        let textAttributesDictionary = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor:textColor]
        let bulletAttributesDictionary = [NSAttributedStringKey.font : font.withSize(bulletSize), NSAttributedStringKey.foregroundColor:bulletColor]
        let fullAttributedString = NSMutableAttributedString.init()
        
        for string: String in strings {
            let bulletPoint: String = "\u{2022}"
            let formattedString: String = "\(bulletPoint) \(string)\n"
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
            let paragraphStyle = createParagraphAttribute()
            
            attributedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            attributedString.addAttributes(textAttributesDictionary, range: NSMakeRange(0, attributedString.length))
            
            let string: NSString = NSString(string: formattedString)
            let rangeForBullet: NSRange = string.range(of: bulletPoint)
            
            attributedString.addAttributes(bulletAttributesDictionary, range: rangeForBullet)
            fullAttributedString.append(attributedString)
        }
        return fullAttributedString
    }
    
    static func createParagraphAttribute() -> NSParagraphStyle {
        
        var paragraphStyle: NSMutableParagraphStyle
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15, options: NSDictionary() as! [NSTextTab.OptionKey : Any])]
        paragraphStyle.defaultTabInterval = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 0
        paragraphStyle.headIndent = 17
        return paragraphStyle
    }
}

