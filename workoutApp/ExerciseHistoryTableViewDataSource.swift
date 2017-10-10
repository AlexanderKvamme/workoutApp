//
//  ExerciseHistoryTableViewDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Data source for the exercise table view used to display all exercises assosciated with a workoutLog. This class is used to get an overview of the performed workout (a workoutLog) in retrospect. So this is not used to add new lifts etc.

class ExerciseHistoryTableViewDataSource: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    weak var owner: ExerciseHistoryTableViewController!
    private let cellIdentifier: String = "exerciseHistoryCell"
    private var exerciseLogsAsArray: [ExerciseLog]! // each entry represents one tableViewCell. So [0] will be the top cell
    private var currentlyDisplayedWorkoutLog: WorkoutLog! // The workoutLog created to track the currently selected workout. Will be added to core data on save, or deleted on dismiss
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    
    // MARK: - Initializers
    
    init(workoutLog: WorkoutLog) {
        super.init()
        setupUsingWorkoutLog(workoutLog)
    }
    
    // MARK: - Methods
    
    // MARK: Setup
    
    private func setupUsingWorkoutLog(_ workoutLog: WorkoutLog) {
        
        // Make new WorkoutLog with the same lifts as the previous one
        currentlyDisplayedWorkoutLog = workoutLog
        
        exerciseLogsAsArray = workoutLog.loggedExercises?.array as! [ExerciseLog]
        totalLiftsToDisplay = Array(repeating: [Lift](), count: exerciseLogsAsArray.count)
        
        for (i, exerciseLog) in exerciseLogsAsArray.enumerated() {
            
            // Sort
            let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: true)
            let sortedLifts = exerciseLog.lifts?.sortedArray(using: [dateSortDescriptor]) as! [Lift]
            
            totalLiftsToDisplay[i] = sortedLifts
        }
    }
    
    // MARK: TableView dataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentlyDisplayedWorkoutLog.loggedExercises?.count ?? 0// uses sections instead of rows to space out cells
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exerciseLog = exerciseLogsAsArray[indexPath.section]
        let liftsToDisplay = totalLiftsToDisplay[indexPath.section]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseHistoryTableViewCell
        cell = ExerciseHistoryTableViewCell(withExerciseLog: exerciseLog, andLifts: liftsToDisplay, andIdentifier: cellIdentifier)
        cell.box.setTitle(exerciseLog.getName())
        cell.owner = self
        
        return cell
    }
}

