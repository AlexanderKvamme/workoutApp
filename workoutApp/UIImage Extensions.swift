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
    static var starIcon: UIImage {
        return UIImage(named: "star-24")!
    }
    static var profileIcon: UIImage {
        return UIImage(named: "profile")!
    }
    static var hexIcon: UIImage {
        return UIImage(named: "hexagon")!.resize(maxWidthHeight: 30)!.rotate(radians: .pi/2)!
    }
    
    static var progressIcon: UIImage {
        return UIImage(named: "progress")!.resize(maxWidthHeight: 30)!//.rotate(radians: .pi/2)!
    }

    static var bodyIcon: UIImage {
        return UIImage(named: "body")!.resize(maxWidthHeight: 30)!
    }

    static var workoutLogoWhiteIcon: UIImage {
        return UIImage(named: "workoutlogowhite")!.resize(maxWidthHeight: 30)!
    }

    static var randomWorkoutIcon: UIImage {
        // Create an octagon with a star inside for the random workout tab
        let size: CGFloat = 48  // Larger base size for better quality
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))

        return renderer.image { context in
            let ctx = context.cgContext

            // Draw octagon (8 sides) filled
            let octagonRadius = size * 0.42
            let center = CGPoint(x: size / 2, y: size / 2)

            // Create octagon path (8 sides)
            let octagonPath = UIBezierPath()
            for i in 0..<8 {
                let angle = CGFloat(i) * (CGFloat.pi / 4) + (CGFloat.pi / 8)  // Octagon
                let point = CGPoint(
                    x: center.x + octagonRadius * cos(angle),
                    y: center.y + octagonRadius * sin(angle)
                )
                if i == 0 {
                    octagonPath.move(to: point)
                } else {
                    octagonPath.addLine(to: point)
                }
            }
            octagonPath.close()

            // Fill octagon
            ctx.setFillColor(UIColor.black.cgColor)
            octagonPath.fill()

            // Draw star inside (in white for contrast)
            let starRadius = size * 0.22
            let starPath = UIBezierPath()

            for i in 0..<10 {
                let angle = CGFloat(i) * (CGFloat.pi / 5) - (CGFloat.pi / 2)
                let radius = i % 2 == 0 ? starRadius : starRadius * 0.45
                let point = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                if i == 0 {
                    starPath.move(to: point)
                } else {
                    starPath.addLine(to: point)
                }
            }
            starPath.close()

            ctx.setFillColor(UIColor.white.cgColor)
            starPath.fill()
        }.resize(maxWidthHeight: 30)!  // Resize to match other tab icons
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

