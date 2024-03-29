

//
//  WorkoutSelectionViewController.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreData

fileprivate var workoutToAutomaticallyEnter: Int? = nil

/// WorkoutSelectionViewController is a list of buttons to provide users with the ability to pick further predicates for which workouts to show. For example when displaying workouts, it displays the different styles. Normal, drop set, etc.
class WorkoutSelectionViewController: SelectionViewController {

    let plusButton = PlusButton()
    var workoutButtons = [SelectionViewButton]()
    
    // MARK: - Initializers
    
    init() {
        super.init(header: SelectionViewHeader(header: "Select", subheader: "Workout Style"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateStackWithEntriesFromCoreData()
        
        view.bringSubviewToFront(stack) // Bring it in front of diagonal line
        view.layoutIfNeeded()
        
        globalTabBar.showIt()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupStack()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugEnterWorkout(workoutToAutomaticallyEnter)
    }
    
    // MARK: - Methods
    
    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(stack)
        
        // Header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // Stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Position stack
        makeAlignmentRectangle()
        stack.centerYAnchor.constraint(equalTo: alignmentRectangle.centerYAnchor, constant: 0).isActive = true
    }
    
    private func setupStack() {
        stack = UIStackView(frame: CGRect.zero)
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.alignment = UIStackView.Alignment.center
        stack.spacing = Constant.components.SelectionVC.Stack.spacing
    }
    
    // Stack methods
    
    /// Sends new fetch and updates buttons
    private func updateStackWithEntriesFromCoreData() {
        let workoutStyles = DatabaseFacade.fetchAllWorkoutStyles()
        workoutButtons = []
    
        buttonIndex = 0
        
        for subview in stack.subviews {
            subview.removeFromSuperview()
        }
        
        // make buttons from unique workout names
        buttonNames = [String]()
        
        for workoutStyle in workoutStyles where workoutStyle.getWorkoutDesignCount() > 0 { //where workoutStyle.usedInWorkoutsCount > 0 {
            let styleName = workoutStyle.getName()
            
            let subheaderString: String = {
                let workoutsOfThisStyle = workoutStyle.getWorkoutDesignCount()
                return workoutsOfThisStyle > 1 ? "\(workoutsOfThisStyle) WORKOUTS" : "\(workoutsOfThisStyle) WORKOUT"
            }()
            
            let newButton = SelectionViewButton(header: styleName, subheader: subheaderString)
            
            // Set up button names etc
            newButton.button.tag = buttonIndex
            newButton.button.accessibilityIdentifier = "\(styleName)"
            buttonIndex += 1
            buttonNames.append(styleName)
            
            // Replace any default target action (Default modal presentation)
            newButton.button.removeTarget(nil, action: nil, for: .allEvents)
            newButton.button.addTarget(self, action: #selector(ShowWorkoutTable), for: UIControl.Event.touchUpInside)
            workoutButtons.append(newButton)
        }
        
        buttons = workoutButtons
        
        // Update stack
        stack.removeArrangedSubviews()
        buttons.forEach(stack.addArrangedSubview(_:))
        addNewWorkoutButton()
        
        stack.layoutIfNeeded()
    }
    
    private func debugEnterWorkout(_ int: Int?) {
        guard let int = int else { return }
        workoutButtons[int].button.sendActions(for: .touchUpInside)
    }
    
    private func addNewWorkoutButton() {
        
        if buttons.count > 0 {
            // Already has selection choices, so place button under the header
            let plusButtonTopSpacing = Constant.UI.headers.headerToPlusButtonSpacing
            plusButton.accessibilityIdentifier = "plus-button"
            
            view.addSubview(plusButton)
            plusButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                plusButton.centerYAnchor.constraint(equalTo: header.bottomAnchor, constant: plusButtonTopSpacing),
                ])
        } else {
            // Add to stackView as only button
            stack.addArrangedSubview(plusButton)
        }
        
        // present newWorkoutController on tap
        plusButton.addTarget(self, action: #selector(pushNewWorkoutController), for: .touchUpInside)
    }
    
    @objc private func pushNewWorkoutController() {
        let newWorkoutController = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutController, animated: true)
    }
    
    @objc func ShowWorkoutTable(button: UIButton) {
        // Identifies which choice was selected and creates a BoxTableView to display
        let tappedWorkoutStyleName = buttonNames[button.tag]
        let boxTable = WorkoutTableViewController(workoutStyleName: tappedWorkoutStyleName)
        
        navigationController?.pushViewController(boxTable, animated: true)
    }
}

