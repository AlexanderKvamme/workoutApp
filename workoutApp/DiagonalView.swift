//
//  DiagonalView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 07/11/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


class TriangleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .light
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: bounds.origin)
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = 5
        shape.strokeColor = UIColor.primary.cgColor
        shape.lineCap = "round"
        
        self.layer.insertSublayer(shape, at: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 200)
    }
}

