//
//  TwoRowStack.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 23/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/// Used in for example the BoxTableViewCells, where each of the Time, Exercises and PR stacks are examples of use
public class TwoRowStack: UIStackView {

    private var stackFont: UIFont = UIFont.custom(style: .bold, ofSize: .medium)
    private var topRow = UILabel()
    private var bottomRow = UILabel()
    
    // MARK: - Initializers
    
    init(topText: String, bottomText: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        setTopLabel(topText)
        bottomRow.text = bottomText.uppercased()
        bottomRow.font = stackFont
        bottomRow.textColor = .lightest
        topRow.textAlignment = .center
        bottomRow.sizeToFit()
    
        addArrangedSubview(topRow)
        addArrangedSubview(bottomRow)
        
        setupStack()
    }
    
    // Set up stack with the following format: "13 x 3"
    convenience init(topText: String, sets: Int, reps: Int) {
        self.init(topText: topText, bottomText: "replace with attributedString")
        self.setTopLabel(topText)

        let attrString = NSMutableAttributedString(string: "\(sets)")
        let xmark = NSTextAttachment()
        xmark.image = UIImage(named: "xmarkBeige")
        xmark.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
        let stringifiedXmark = NSAttributedString(attachment: xmark)
        attrString.append(stringifiedXmark)
        attrString.append(NSAttributedString(string: "\(reps)"))
        
        bottomRow.attributedText = attrString
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setTopLabel(_ str: String) {
        topRow.text = str.uppercased()
        topRow.font = stackFont
        topRow.textColor = .light
        topRow.textAlignment = .center
        topRow.sizeToFit()
    }
    
    private func setupStack() {
        distribution = .equalCentering
        alignment = .center
        axis = .vertical
        spacing = 0
    }
    
    // MARK: - Public Access
    
    func setTopText(_ str: String) {
        topRow.text = str
    }
    
    func setBottomText(_ str: String) {
        bottomRow.text = str
    }
}

