//
//  SelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit

class ProgressViewController: SelectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .light
        
        // header
        header = SelectionViewHeader(header: "SELECT", subheader: "DEVELOPMENT")
        view.addSubview(header)
        
        // make buttons
        let statisticsButton = SelectionViewButton(header: "STATISTICS", subheader: "292 EXERCISES")
        let workoutHistoryButton = SelectionViewButton(header: "WORKOUT HISTORY", subheader: "99 WORKOUTS")
        let testButton = SelectionViewButton(header: "TEMPORARY TEST", subheader: "4 WORKOUTS")
        
        // stack
        
        buttonStack.addArrangedSubview(statisticsButton)
        buttonStack.addArrangedSubview(workoutHistoryButton)
        buttonStack.addArrangedSubview(testButton)
        buttonStack.axis = .vertical
        buttonStack.spacing = 50
        view.addSubview(buttonStack)
        
        setLayout()
    }
}
