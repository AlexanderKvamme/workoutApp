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
        
        // Create ButtonGridItems from workout styles
        var gridItems: [ButtonGridItem] = []
        
        // Process workout styles
        let uniqueWorkoutTypes = Set(workoutStyles)
        for workoutStyle in uniqueWorkoutTypes where workoutStyle.getPerformanceCount() > 0 {
            let styleName = workoutStyle.getName()
            let count = workoutStyle.getPerformanceCount()
            let pluralEnding = count == 1 ? "LOG" : "LOGS"
            
            let gridItem = ButtonGridItem(
                title: styleName,
                icon: nil,
                color: .black,
                font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
            ) { [weak self] in
                self?.showTableForWorkoutStyle(styleName: styleName)
            }
            
            gridItems.append(gridItem)
            buttonNames.append(styleName)
            buttonIndex += 1
        }
        
        // Add "All" button at the end
        let allButtonItem = ButtonGridItem(
            title: "All",
            icon: nil,
            color: .black,
            font: h2 ?? UIFont.boldSystemFont(ofSize: 20)
        ) { [weak self] in
            self?.showTableOfAllWorkouts()
        }
        gridItems.append(allButtonItem)
        
        // Create button grid with dynamic layout
        buttonGrid = ButtonGridView(items: gridItems, buttonsPerRow: 2)
        
        if let buttonGrid = buttonGrid {
            view.addSubview(buttonGrid)
            
            NSLayoutConstraint.activate([
                buttonGrid.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
                buttonGrid.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
                buttonGrid.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                buttonGrid.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200)
            ])
        }
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
