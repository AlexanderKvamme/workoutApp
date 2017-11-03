//
//  DiagonalLineView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 15/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class DiagonalLineView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw stuff
        let rect = UIBezierPath(roundedRect: CGRect(x: 150, y: 150, width: 100, height: 100), cornerRadius: 5.0)
        UIColor.green.set()
        rect.fill()
    }
}
