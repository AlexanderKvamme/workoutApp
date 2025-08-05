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

    // Replace the stack with ButtonGridView
    private var buttonGrid: ButtonGridView?
    
    // MARK: - Initializers
    
    init() {
        super.init(header: AnimatedScreenHeader(header: "workout", subheader: "History"))
        DatabaseFacade.clearUnfininishedWorkoutLogs() // Removes unfinished workouts
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .akLight
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateButtonGridWithEntriesFromCoreData()
        view.layoutIfNeeded()
        
        header.play()
    }
    
    // MARK: - Methods
    
    private func setupLayout() {
        view.addSubview(header)
        
        // Header
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: Constant.components.SelectionVC.Header.spacingTop).isActive = true
    }
    
    /// Sends new fetch and updates button grid
    private func updateButtonGridWithEntriesFromCoreData() {
        let workoutStyles = DatabaseFacade.fetchAllWorkoutStyles()
        
        // Clear existing data
        buttonNames = [String]()
        buttonIndex = 0
        
        // Remove existing button grid
        buttonGrid?.removeFromSuperview()
        buttonGrid = nil
        
        // Create container stack view
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.spacing = 16
        containerStack.alignment = .center
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Create top row (WEIGHTED only)
        let topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.spacing = 16
        topRowStack.alignment = .center
        
        // Create bottom row (ALL + IMPROV)
        let bottomRowStack = UIStackView()
        bottomRowStack.axis = .horizontal
        bottomRowStack.spacing = 16
        bottomRowStack.alignment = .center
        
        // Create buttons
        var improvButton: FormFittingActionButton?
        var weightedButton: FormFittingActionButton?
        
        // Process workout styles
        let uniqueWorkoutTypes = Set(workoutStyles)
        for workoutStyle in uniqueWorkoutTypes where workoutStyle.getPerformanceCount() > 0 {
            let styleName = workoutStyle.getName()
            
            let button = FormFittingActionButton(
                title: styleName,
                icon: nil,
                color: .black,
                font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
            ) { [weak self] in
                self?.showTableForWorkoutStyle(styleName: styleName)
            }
            
            if styleName == "IMPROV" {
                improvButton = button
            } else if styleName == "WEIGHTED" {
                weightedButton = button
            }
            
            buttonNames.append(styleName)
            buttonIndex += 1
        }
        
        // Create ALL button
        let allButton = FormFittingActionButton(
            title: "All",
            icon: nil,
            color: .black,
            font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
        ) { [weak self] in
            self?.showTableOfAllWorkouts()
        }
        
        // Add buttons to rows - SWAPPED POSITIONS
        if let weightedButton = weightedButton {
            topRowStack.addArrangedSubview(weightedButton)  // WEIGHTED now in top row
        }
        
        bottomRowStack.addArrangedSubview(allButton)
        if let improvButton = improvButton {
            bottomRowStack.addArrangedSubview(improvButton)  // IMPROV now in bottom row
        }
        
        // Add rows to container
        containerStack.addArrangedSubview(topRowStack)
        containerStack.addArrangedSubview(bottomRowStack)
        
        // Add to view
        view.addSubview(containerStack)
        
        NSLayoutConstraint.activate([
            containerStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            containerStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            containerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200)
        ])
    }

    
    // MARK: - TapHandlers
    
    @objc func showTableOfAllWorkouts() {
        let historyTableViewController = WorkoutLogHistoryTableViewController(workoutStyleName: nil)
        navigationController?.pushViewController(historyTableViewController, animated: true)
    }
    
    private func showTableForWorkoutStyle(styleName: String) {
        let historyTableViewController = WorkoutLogHistoryTableViewController(workoutStyleName: styleName)
        navigationController?.pushViewController(historyTableViewController, animated: true)
    }
    
    // Legacy method for compatibility
    @objc func showTableForWorkoutStyle(button: UIButton) {
        guard button.tag < buttonNames.count else { return }
        let tappedWorkoutStyleName = buttonNames[button.tag]
        showTableForWorkoutStyle(styleName: tappedWorkoutStyleName)
    }
}
