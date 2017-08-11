//
//  GoalsButton.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 10/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit


/// Subclass of UIButton to make label and the frame of the button equal
class GoalButton: UIButton {
    
    // MARK: - Properties
    
    var goal: Goal!
    
    // MARK: - Initializer
    
    init(withGoal goal: Goal) {
        super.init(frame: .zero)
        self.goal = goal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return self.titleLabel!.intrinsicContentSize
    }
    
    // Whever the button is changed or needs to layout subviews,
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
    
    public func deleteFromCoreData() {
        DatabaseFacade.delete(goal)
    }
}

