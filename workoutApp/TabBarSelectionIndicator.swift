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
    let indicatorHorizontalShrinkage: CGFloat = 30
    lazy var indicatorWidth: CGFloat = Constant.UI.width/CGFloat(self.tabBarCount) - indicatorHorizontalShrinkage
    lazy var itemLength = Constant.UI.width/CGFloat(tabBarCount)
    
    // MARK: - Initializers
    
    init(tabBarItemcount: Int) {
        self.tabBarCount = tabBarItemcount
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.darkest
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: indicatorWidth, height: indicatorHeight)
    }
}

