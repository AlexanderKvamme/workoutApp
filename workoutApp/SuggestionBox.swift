//
//  SuggestionBox.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//


import Foundation
import UIKit

/// Header is the topLabel, describing time since last workout.. subHeader is the bottomLabel, explaining which muscle you should work out next
class SuggestionBox: Box {

    var stack: UIStackView!
    
    // MARK: - Initializers
    
    init() {
        let boxFactory = BoxFactory.makeFactory(type: .SuggestionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        boxFrame?.background.backgroundColor = .white
        boxHeader?.boxHeaderLabel.textColor = .akDark.withAlphaComponent(.opacity.barelyFaded.rawValue)
        boxHeader?.boxHeaderLabel.font = UIFont.custom(style: .bold, ofSize: .small)
        boxSubHeader?.label.textColor = .akDark
        
        super.init(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        
        setupViews()
        makeTappable()
    }
    
    /// Set header and subheader based on injected muscle
    convenience init(withMuscle muscle: Muscle) {
        self.init()
        
        var subHeaderText = ""
        
        // Set suggestion header based on when it was performed
        if let timeOfWorkout = muscle.lastPerformance() {
            let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
            let shortTimeInterval = timeIntervalSinceWorkout.asShortString()
            subHeaderText = "\(shortTimeInterval)"
        } else {
            subHeaderText =  "Never performed"
        }
        
        setSuggestionHeader(subHeaderText)
        setSuggestionSubheader(muscle.getName())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width-48, height: 80)
    }
    
    // MARK: - Methods
    
    private func setupViews() {
        setupHeader()
        setupSubheader()
        setupBoxFrame()
    }
    
    private func setupBoxFrame() {
        // Position boxFrame via autolayout
        clipsToBounds = false
        
        boxFrame.translatesAutoresizingMaskIntoConstraints = false
        boxFrame.frame = frame
    }
    
    private func setupHeader() {
        guard let header = header else {
            return
        }
        
        header.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSubheader() {
        guard let header = header else { return }
        guard let subheader = subheader else { return }
        
        stack = UIStackView(frame: frame)
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = 0
        stack.addArrangedSubview(subheader)
        stack.addArrangedSubview(header)
        stack.isUserInteractionEnabled = false
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        subheader.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setSuggestionHeader(_ str: String) {
        guard let header = header else { return }
        header.boxHeaderLabel.text = str
    }
    
    func setSuggestionSubheader(_ str: String) {
        guard let subheader = subheader else { return }
        subheader.label.text = str
    }
    
    private func makeTappable() {
        clipsToBounds = true
        button.backgroundColor = .clear // alpha of 0 disables button
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

