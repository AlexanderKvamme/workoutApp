
//
//  File.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/06/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

func drawDiagonalLineThrough(_ someView: UIView, inView view: UIView) {
    view.layoutSubviews()
    let verticalShift: CGFloat = 24
    let verticalStretch: CGFloat = 30
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: someView.frame.minX, y: someView.frame.maxY + verticalStretch - verticalShift))
    path.addLine(to: CGPoint(x: someView.frame.maxX, y: someView.frame.minY - verticalStretch - verticalShift))
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = UIColor.primary.cgColor
    shapeLayer.lineCap = "round"
    shapeLayer.lineWidth = 3.0
    
    let line = UIView()
    line.layer.addSublayer(shapeLayer)
    view.addSubview(line)
    view.sendSubview(toBack: line)
}
