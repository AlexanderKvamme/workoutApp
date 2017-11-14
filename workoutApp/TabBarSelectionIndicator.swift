//
//  tabBarSelectionIndicatorView.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// A view that is displayed over the tabBar do indicate which one is selected
class TabBarSelectionIndicator: UIView {
    
    // MARK: - Properties
    
    let tabBarCount: Int
    let indicatorHeight: CGFloat = 10
    let indicatorHorizontalSpacing: CGFloat = 30
    lazy var indicatorWidth: CGFloat = Constant.UI.width/CGFloat(self.tabBarCount) - indicatorHorizontalSpacing
    
    // MARK: - Initializers
    
    init(count: Int) {
        self.tabBarCount = count
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = UIColor.darkest
        setup(selectableItemsCount: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: indicatorWidth, height: indicatorHeight)
    }
    
    func setup(selectableItemsCount itemCount: Int) {
        let indicatorHeight: CGFloat = 10
        let indicatorWidth: CGFloat = Constant.UI.width/CGFloat(itemCount) - indicatorHorizontalSpacing
        
        self.frame.size = CGSize(width: indicatorWidth, height: indicatorHeight)
  
        self.backgroundColor = UIColor.darkest
    }
    
    func moveToItem(_ i: Int, ofItemCount items: Int) {
        
        let itemLength = Constant.UI.width/CGFloat(items)
        
        UIView.animate(withDuration: 0.2) {
            self.frame.origin.x = itemLength*CGFloat(i) + self.indicatorHorizontalSpacing/2
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.frame.origin.x = itemLength*CGFloat(i) + self.indicatorHorizontalSpacing/2
        })
    }
}

