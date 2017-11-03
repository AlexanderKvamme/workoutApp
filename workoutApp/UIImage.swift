//
//  UIImage.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 15/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


// MARK: Images

extension UIImage {
    
    static var messageIcon: UIImage {
        return UIImage(named: "messageIconThick")!
    }
    
    static var xmarkIcon: UIImage {
        return UIImage(named: "xmark")!
    }
    
    static var checkmarkIcon: UIImage {
        return UIImage(named: "checkmark")!
    }
    
    static var plusIcon: UIImage {
        return UIImage(named: "plusIcon")!
    }
    
    static var wrenchIcon: UIImage {
        return UIImage(named: "wrench")!
    }
    
    static var backArrowIcon: UIImage {
        return UIImage(named: "backArrow")!
    }
    
    static var historyIcon: UIImage {
        return UIImage(named: "history")!
    }
    static var workoutIcon: UIImage {
        return UIImage(named: "workout")!
    }
    static var profileIcon: UIImage {
        return UIImage(named: "profile")!
    }
    
}

// MARK: Method to resize
extension UIImage {
    
    func resize(maxWidthHeight : Double)-> UIImage? {
        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0
        
        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        } else {
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }
        
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}

