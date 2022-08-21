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

    // MARK: - Initializers
    
    init() {
        let boxFactory = BoxFactory.makeFactory(type: .SuggestionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        boxFrame?.background.backgroundColor = .orange
        boxContent?.backgroundColor = .green
        
        boxHeader?.boxHeaderLabel.textColor = .akDark
        boxSubHeader?.label.textColor = .akDark
        
        boxFrame?.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
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
            let shortTimeInterval = timeIntervalSinceWorkout.asMinimalString()
            subHeaderText = "\(shortTimeInterval) SINCE:"
        } else {
            subHeaderText =  "NEVER PERFORMED"
        }
        
        setSuggestionHeader(subHeaderText)
        setSuggestionSubheader(muscle.getName())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.components.box.suggestion.width, height: 80)
    }
    
    // MARK: - Methods
    
    private func setupViews() {
        setupHeader()
        setupSubheader()
        setupBoxFrame()
        setupShimmer()
    }
    
    private func setupBoxFrame() {
        // Position boxFrame via autolayout
        clipsToBounds = false
        
        boxFrame.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            boxFrame.leftAnchor.constraint(equalTo: leftAnchor),
            boxFrame.rightAnchor.constraint(equalTo: rightAnchor),
            boxFrame.topAnchor.constraint(equalTo: topAnchor),
            boxFrame.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    private func setupShimmer() {
        // Position shimmer via autolayout
        let shimmerInset = Constant.components.box.suggestion.shimmerInset
        
        boxFrame.shimmer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            boxFrame.shimmer.leftAnchor.constraint(equalTo: boxFrame.leftAnchor, constant: shimmerInset),
            boxFrame.shimmer.rightAnchor.constraint(equalTo: boxFrame.rightAnchor, constant: -shimmerInset),
            boxFrame.shimmer.topAnchor.constraint(equalTo: boxFrame.topAnchor, constant: shimmerInset),
            boxFrame.shimmer.bottomAnchor.constraint(equalTo: boxFrame.bottomAnchor, constant: -shimmerInset),
            ])
    }
    
    private func setupHeader() {
        guard let header = header else {
            return
        }
        
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: boxFrame.leftAnchor),
            header.rightAnchor.constraint(equalTo: boxFrame.rightAnchor),
            header.centerXAnchor.constraint(equalTo: boxFrame.centerXAnchor),
            header.topAnchor.constraint(equalTo: boxFrame.shimmer.topAnchor, constant: 5),
            ])
    }
    
    private func setupSubheader() {
        guard let header = header else { return }
        guard let subheader = subheader else { return }
        
        subheader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subheader.leftAnchor.constraint(equalTo: boxFrame.leftAnchor),
            subheader.rightAnchor.constraint(equalTo: boxFrame.rightAnchor),
            subheader.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -5),
            ])
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
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leftAnchor.constraint(equalTo: leftAnchor),
            button.rightAnchor.constraint(equalTo: rightAnchor),
            ])
    }
}

