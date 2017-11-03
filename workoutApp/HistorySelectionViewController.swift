//
//  HistorySelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 30/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

/// Helps user navigate through the different workoutStyles and list out the history of performed workouts (as WorkoutLog items)
class HistorySelectionViewController: SelectionViewController {

    // MARK: - Initializers
    
    init() {
        super.init(header: SelectionViewHeader(header: "Workout", subheader: "History"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .light
        setupStack()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateStackToDisplayStylesAndAll()
        drawDiagonalLine()
        view.bringSubview(toFront: stack) // Bring above diagonal line
        view.layoutIfNeeded()
    }
    
    // MARK: - Methods
    
    private func makeAllButton() -> SelectionViewButton {
        let allButton = SelectionViewButton(header: "All", subheader: "workouts")
        allButton.button.removeTarget(nil, action: nil, for: .allEvents)
        allButton.button.addTarget(self, action: #selector(showTableOfAllWorkouts), for: .touchUpInside)
        return allButton
    }
    
    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(stack)
        
        // header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor,
                                    constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Position stack
        makeAlignmentRectangle()
        stack.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor, constant: 0).isActive = true
    }
    
    private func setupStack() {
        stack = UIStackView(frame: CGRect.zero)
        stack.axis = UILayoutConstraintAxis.vertical
        stack.distribution = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing = Constant.components.SelectionVC.Stack.spacing
    }
    
    /// Sends new fetch and updates buttons
    private func updateStackToDisplayStylesAndAll() {
        let workoutStyles = getUniqueWorkoutStyles()
        
        buttonIndex = 0

        stack.removeArrangedSubviews()
        
        // make buttons from unique workout names
        var workoutButtons = [SelectionViewButton]()
        let uniqueWorkoutTypes = Set(workoutStyles)
        buttonNames = [String]()
        buttons = [SelectionViewButton]()
        
        let allButton = makeAllButton()
        buttons.append(allButton)
        
        // Set up all the unique styles choices
        for type in uniqueWorkoutTypes {
            guard let styleName = type.name else { return }
            
            let newButton = SelectionViewButton(header: styleName, subheader: "\(DatabaseFacade.countWorkoutLogs(ofStyle: styleName)) WORKOUTS")
            
            // Set up button names etc
            newButton.button.tag = buttonIndex
            buttonIndex += 1
            buttonNames.append(styleName)
            
            // Replace any default target action (Default modal presentation)
            newButton.button.removeTarget(nil, action: nil, for: .allEvents)
            newButton.button.addTarget(self, action: #selector(showTableForWorkoutStyle), for: UIControlEvents.touchUpInside)
            
            workoutButtons.append(newButton)
        }
        
        buttons += workoutButtons
        
        // Update stack
        stack.removeArrangedSubviews()
        buttons.forEach(stack.addArrangedSubview(_:))
        stack.layoutIfNeeded()
    }
    
    // MARK: - TapHandlers 
    
    @objc func showTableOfAllWorkouts() {
        let historyTableViewController = WorkoutLogHistoryTableViewController(workoutStyleName: nil)
        navigationController?.pushViewController(historyTableViewController, animated: true)
    }
    
    @objc func showTableForWorkoutStyle(button: UIButton) {
        // Identifies which choice was selected and creates a BoxTableView to display
        let tappedWorkoutStyleName = buttonNames[button.tag]
        let historyTableViewController = WorkoutLogHistoryTableViewController(workoutStyleName: tappedWorkoutStyleName)
        
        navigationController?.pushViewController(historyTableViewController, animated: true)
    }
}

