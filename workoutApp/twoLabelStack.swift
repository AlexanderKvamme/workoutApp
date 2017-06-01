//
//  twoStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class twoLabelStack: UIView {
    
    /*
     Vertical label stack
     */

    var topLabel: UILabel!
    var bottomLabel: UILabel!
    var button: UIButton!
    var verticalStack = UIStackView()

    // MARK: - Init
    
    init(topText: String, topFont: UIFont, topColor: UIColor, bottomText: String, bottomFont: UIFont, bottomColor: UIColor, faded: Bool) {
        super.init(frame: CGRect.zero)
        topLabel = UILabel()
        topLabel.text = topText
        topLabel.font = topFont
        topLabel.textColor = topColor
        topLabel.sizeToFit()
        addSubview(topLabel)
        
        bottomLabel = UILabel()
        bottomLabel.text = bottomText
        bottomLabel.font = bottomFont
        bottomLabel.textColor = bottomColor
        bottomLabel.sizeToFit()
        addSubview(bottomLabel)
        
        if faded == true {
            bottomLabel.alpha = Constant.alpha.faded
        }
        
        setup()
        enableDebugColors()
        
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setup(){
        setupStack()
    }
    
    private func setupStack() {
        verticalStack.distribution = .equalSpacing
        verticalStack.alignment = .center
        verticalStack.axis = .vertical
        verticalStack.spacing = 0
        
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStack.addArrangedSubview(topLabel)
        verticalStack.addArrangedSubview(bottomLabel)
        
        addSubview(verticalStack)
        
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        verticalStack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        
        setNeedsLayout()
    }
    
    private func enableDebugColors() {
        topLabel.backgroundColor = .purple
        bottomLabel.backgroundColor = .green
        backgroundColor = .yellow
    }
}
