//
//  TallExerciseTableCellBox.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class TallExerciseTableCellBox: ExerciseTableCellBox {
    
    override func setup() {
        
        var totalHeight: CGFloat = 0
        
        // BoxFrame
        boxFrame.frame.origin = CGPoint(x: Constant.components.box.spacingFromSides, y: header?.frame.height ?? 0)
        addSubview(boxFrame)
        
        // Content
        if let content = content {
            content.frame = boxFrame.frame
            addSubview(content)
        }
        
        // Header
        if let header = header {
            addSubview(header)
            bringSubview(toFront: header)
            totalHeight += header.frame.height
        }
        
        // Calculate the frame
        totalHeight += boxFrame.frame.height
        frame = CGRect(x: 0, y: 0, width: boxFrame.frame.width + 2*Constant.components.box.spacingFromSides, height: totalHeight)
        
        // Subheader
        if let subheader = subheader {
            addSubview(subheader)
            subheader.frame.origin = CGPoint(x: Constant.components.box.spacingFromSides, y: header!.boxHeaderLabel.frame.maxY - subheader.frame.height)
            bringSubview(toFront: subheader)
        }
        
        // Invisible button
        button.frame = boxFrame.frame
        addSubview(button)
        
        setNeedsLayout()
    }
}

