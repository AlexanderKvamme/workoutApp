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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            print("had header")
            header.label.text = str
        } else {
            print("had no header")
        }
    }
    
    func setSuggestionSubheader(_ str: String) {
        subheader?.label.text = str
    }
}

