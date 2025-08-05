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
    
    // Add badge button
    private lazy var badgeButton: UIButton = {
        var hSpace = CGFloat(16)
        var config = UIButton.Configuration.filled()
        config.title = "new"
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: hSpace, bottom: 4, trailing: hSpace)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = h3.withSize(18)
            return outgoing
        }
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(badgeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(header: AnimatedScreenHeader(header: "Start", subheader: "A workout"))
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
        header.play()
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
        view.addSubview(badgeButton) // Add badge button to view
        
        // Header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // Stack
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // Badge button constraints - top right corner
        NSLayoutConstraint.activate([
            badgeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            badgeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            badgeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
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
    
    // MARK: - Badge Button Action
    
    @objc private func badgeButtonTapped() {
        print("hello")
        
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
