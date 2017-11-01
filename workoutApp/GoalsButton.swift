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
    
    var goal: Goal
    
    // MARK: - Initializer
    
    init(withGoal goal: Goal) {
        self.goal = goal
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    // Size of each GoalButton should be the size of the text it holds
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

