//
//  tabBarSelectionIndicatorView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class tabBarSelectionIndicatorView: UIView {
    
    let indicatorHorizontalSpacing: CGFloat = 30
    
    func setup(selectableItemsCount itemCount: Int, atHeight tabBarHeight: CGFloat) {
        let indicatorHeight: CGFloat = 10
        let indicatorWidth: CGFloat = Constant.UI.width/CGFloat(itemCount) - indicatorHorizontalSpacing
        
        self.frame.size = CGSize(width: indicatorWidth, height: indicatorHeight)
        self.frame.origin = CGPoint(x: -200, y: tabBarHeight-indicatorHeight/2)
        self.backgroundColor = UIColor.dark
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func moveToItem(_ i: Int, ofItemCount items: Int) {
        
        let itemLength = Constant.UI.width/CGFloat(items)
        
        UIView.animate(withDuration: 0.2) {
            self.frame.origin.x = itemLength*CGFloat(i) + self.indicatorHorizontalSpacing/2
        }
    }
}
