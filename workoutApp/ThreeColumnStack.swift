//
//  3times2Stack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class ThreeColumnStack: UIStackView {
    
    var firstStack: TwoRowStack!
    var secondStack: TwoRowStack!
    var thirdStack: TwoRowStack!
    
    // Usage
    
    func highlightBottomRow() {
        thirdStack.bottomRow.textColor = .secondary
    }
}

extension ThreeColumnStack {
    convenience init(withSubstacks first: TwoRowStack, _ second: TwoRowStack, _ third: TwoRowStack) {
        self.init()
        
        firstStack = first
        secondStack = second
        thirdStack = third
        
        addArrangedSubview(firstStack)
        addArrangedSubview(secondStack)
        addArrangedSubview(thirdStack)
    }
}
