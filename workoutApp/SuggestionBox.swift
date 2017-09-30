//
//  SuggestionBox.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//


import Foundation
import UIKit

/*
 Header is the topLabel, describing time since last workout
 subHeader is the bottomLabel, explaining which muscle
 */

class SuggestionBox: Box {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    init() {
        let boxFactory = BoxFactory.makeFactory(type: .SuggestionBox)
        let boxHeader = boxFactory.makeBoxHeader()
        let boxSubHeader = boxFactory.makeBoxSubHeader()
        let boxFrame = boxFactory.makeBoxFrame()
        let boxContent = boxFactory.makeBoxContent()
        
        super.init(header: boxHeader, subheader: boxSubHeader, bgFrame: boxFrame!, content: boxContent)
        
        setupViews()
        makeTappable()
    }
    
    /// Set header and subheader based on injected muscle
    convenience init(withMuscle muscle: Muscle) {
        self.init()
        
        var subHeaderText = ""
        if let timeOfWorkout = muscle.lastPerformance() {
            // Has been performed before
            let timeIntervalSinceWorkout = Date().timeIntervalSince(timeOfWorkout as Date)
            let shortTimeInterval = timeIntervalSinceWorkout.asMinimalString()
            subHeaderText = "\(shortTimeInterval) SINCE LAST WORKOUT OF:"
        } else {
            subHeaderText =  "YET TO BE WORKED OUT"
        }
        
        setSuggestionHeader(subHeaderText)
        setSuggestionSubheader(muscle.getName())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Constant.UI.width, height: 80)
    }
    
    // MARK: - Methods
    
    private func setupViews() {
        setupHeader()
        setupSubheader()
    }
    
    private func setupHeader() {
        guard let header = header else { return }
        
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
        if let header = header {
            header.label.text = str
        }
    }
    
    func setSuggestionSubheader(_ str: String) {
        if let subheader = subheader {
            subheader.label.text = str
        }
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

