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
    
    // Replace the stack with ButtonGridView
    private var buttonGrid: ButtonGridView?
    
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

        updateButtonGridWithEntriesFromCoreData()
        
        view.layoutIfNeeded()
        
        globalTabBar.showIt()
        header.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        debugEnterWorkout(workoutToAutomaticallyEnter)
    }
    
    // MARK: - Methods
    
    private func setupLayout() {
        view.addSubview(header)
        view.addSubview(badgeButton)
        
        // Header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
        
        // Badge button constraints - top right corner
        NSLayoutConstraint.activate([
            badgeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            badgeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Badge Button Action
    
    @objc private func badgeButtonTapped() {
        print("hello")
    }
    
    // Button Grid methods
    
    /// Sends new fetch and updates button grid
    private func updateButtonGridWithEntriesFromCoreData() {
        let workoutStyles = DatabaseFacade.fetchAllWorkoutStyles()
        
        // Clear existing data
        buttonNames = [String]()
        buttonIndex = 0
        
        // Create ButtonGridItems from workout styles
        var gridItems: [ButtonGridItem] = []
        
        for workoutStyle in workoutStyles where workoutStyle.getWorkoutDesignCount() > 0 {
            let styleName = workoutStyle.getName()
            
            let subheaderString: String = {
                let workoutsOfThisStyle = workoutStyle.getWorkoutDesignCount()
                return workoutsOfThisStyle > 1 ? "\(workoutsOfThisStyle) WORKOUTS" : "\(workoutsOfThisStyle) WORKOUT"
            }()
            
            // Create ButtonGridItem
            let gridItem = ButtonGridItem(
                title: styleName,
                icon: nil, // Add icons if you want
                color: .black, // Customize colors
                font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
            ) { [weak self] in
                self?.showWorkoutTable(for: styleName)
            }
            
            gridItems.append(gridItem)
            buttonNames.append(styleName)
            buttonIndex += 1
        }
        
        // Create or update button grid
        if let existingGrid = buttonGrid {
            existingGrid.updateItems(gridItems)
        } else {
            // Create new button grid
            buttonGrid = ButtonGridView(items: gridItems, buttonsPerRow: 1) // 1 button per row to match original layout
            
            if let buttonGrid = buttonGrid {
                view.addSubview(buttonGrid)
                
                // Use same bottom spacing as CreatorScreen (-200)
                NSLayoutConstraint.activate([
                    buttonGrid.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
                    buttonGrid.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
                    buttonGrid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    buttonGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200) // Same as CreatorScreen
                ])
            }
        }
        
        addNewWorkoutButton()
    }
    
    private func debugEnterWorkout(_ int: Int?) {
        guard let int = int, int < buttonNames.count else { return }
        showWorkoutTable(for: buttonNames[int])
    }
    
    private func addNewWorkoutButton() {
        // Remove existing plus button
        plusButton.removeFromSuperview()
        
        if buttonNames.count > 0 {
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
            // Add to center if no buttons exist, but respect the same bottom spacing
            view.addSubview(plusButton)
            plusButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200) // Same spacing as buttons
            ])
        }
        
        // present newWorkoutController on tap
        plusButton.removeTarget(nil, action: nil, for: .allEvents)
        plusButton.addTarget(self, action: #selector(pushNewWorkoutController), for: .touchUpInside)
    }
    
    @objc private func pushNewWorkoutController() {
        let newWorkoutController = NewWorkoutController()
        navigationController?.pushViewController(newWorkoutController, animated: true)
    }
    
    private func showWorkoutTable(for workoutStyleName: String) {
        let boxTable = WorkoutTableViewController(workoutStyleName: workoutStyleName)
        navigationController?.pushViewController(boxTable, animated: true)
    }
    
    // Legacy method for compatibility
    @objc func ShowWorkoutTable(button: UIButton) {
        guard button.tag < buttonNames.count else { return }
        let tappedWorkoutStyleName = buttonNames[button.tag]
        showWorkoutTable(for: tappedWorkoutStyleName)
    }
}
