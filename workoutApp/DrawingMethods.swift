
//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Takes a view to draw line through. Also takes that views container view as a parameter, to make sure it is drawn in the back of it.
func drawDiagonalLineThrough(_ someView: UIView) -> UIView {
    // Properties
    let verticalStretch: CGFloat = 30
    
    // Draw line
    let path = UIBezierPath()
    path.move(to: CGPoint(x: someView.frame.minX, y: someView.frame.maxY + verticalStretch))
    path.addLine(to: CGPoint(x: someView.frame.maxX, y: someView.frame.minY - verticalStretch))
    
    // Make shapelayer to display line
    let shapeLayer = CAShapeLayer()
    shapeLayer.frame.size = someView.frame.size
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = UIColor.primary.cgColor
    shapeLayer.lineCap = .round
    shapeLayer.lineWidth = 3.0
    
    // wrap line in view
    let lineWrapper = UIView()
    lineWrapper.frame.size = someView.frame.size
    lineWrapper.backgroundColor = .red
    lineWrapper.layer.addSublayer(shapeLayer)
    
    return lineWrapper
}

