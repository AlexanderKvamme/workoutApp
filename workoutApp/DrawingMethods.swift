
//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Global method for draw
func getDiagonalLineView(sizeOf v: UIView) -> UIView {
    // Properties
    let verticalStretch: CGFloat = 30
    
    // Draw lije
    let path = UIBezierPath()
    path.move(to: CGPoint(x: v.frame.minX, y: v.frame.maxY + verticalStretch))
    path.addLine(to: CGPoint(x: v.frame.maxX, y: v.frame.minY - verticalStretch))
    
    // Make Shapelayer with line
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = UIColor.primary.cgColor
    shapeLayer.lineCap = "round"
    shapeLayer.lineWidth = 3.0
    
    // Wrap shapelayer in a view
    let lineWrapperView = UIView(frame: v.frame)
    lineWrapperView.layer.addSublayer(shapeLayer)
    
    return lineWrapperView
}

/// Takes a view to draw line through. Also takes that views container view as a parameter, to make sure it is drawn in the back of it.
func drawDiagonalLineThrough(_ someView: UIView, inView view: UIView) {
    // Properties
    let verticalStretch: CGFloat = 30
    
    // Draw line
    let path = UIBezierPath()
    path.move(to: CGPoint(x: someView.frame.minX, y: someView.frame.maxY + verticalStretch))
    path.addLine(to: CGPoint(x: someView.frame.maxX, y: someView.frame.minY - verticalStretch))
    
    // Make shapelayer to display line
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = UIColor.primary.cgColor
    shapeLayer.lineCap = "round"
    shapeLayer.lineWidth = 3.0
    
    // wrap line in view
    let lineWrapper = UIView()
    lineWrapper.layer.addSublayer(shapeLayer)
    view.addSubview(lineWrapper)
    view.sendSubview(toBack: lineWrapper)
}

