//
//  ExerciseHistoryTableViewDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 18/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

//
//  ExerciseDataSource.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 01/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Data source for the exercise table view used to display all exercises assosciated with a workout. So you tap a workout, and you enter a tableview with all exercises owned by that workout. This class is the datasource that provides these items.

class ExerciseHistoryTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier: String = "exerciseCell"
    
    // Data source methods
    var exerciseLogsAsArray: [ExerciseLog]! // each entry represents one tableViewCell. So [0] will be the topmost cell
    private var dataSourceWorkoutLog: WorkoutLog! // The workoutLog created to track the currently selected workout. Will be added to core data on save, or deleted on dismiss
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    weak var owner: ExerciseHistoryTableViewController!
    
    // MARK: - Initializers
    
    init(workoutLog: WorkoutLog) {
        super.init()
        setupUsingWorkoutLog(mostRecentPerformance: workoutLog)
    }
    
    // MARK: - Methods
    
    // MARK: Setup
    
    // convenience init to allow initialization from a WorkoutLog (latest WorkoutLog)
    private func setupUsingWorkoutLog(mostRecentPerformance inputtedWorkoutLog: WorkoutLog) {
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog and make it identical to the previous one
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = inputtedWorkoutLog.design
        
        //if let exercisesFromInputtedWorkoutLog = inputtedWorkoutLog.loggedExercises as? Set<ExerciseLog> {
        
        if let exercisesFromInputtedWorkoutLog = inputtedWorkoutLog.loggedExercises?.array as? [ExerciseLog] {
            
            totalLiftsToDisplay = Array(repeating: [Lift](), count: exercisesFromInputtedWorkoutLog.count)
            
            var i = 0
            
            // for each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
            
            for exercise in exercisesFromInputtedWorkoutLog {
                
                //make new ExerciseLog
                let newExerciseLog = DatabaseFacade.makeExerciseLog()
                newExerciseLog.exerciseDesign = exercise.exerciseDesign
                newExerciseLog.usedIn = dataSourceWorkoutLog
                newExerciseLog.datePerformed = Date() as NSDate
                
                var liftCopies = [Lift]()
                
                // Copy values from the most recently performed ExerciseLog to the newly created one
                
                // SortDescriptor
                let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: true)
                let sortedRecentLifts = exercise.lifts?.sortedArray(using: [dateSortDescriptor]) as! [Lift]
                
                // copy each Lift and add them to the newExerciseLog
                for lift in sortedRecentLifts {
                    let newLift = DatabaseFacade.makeLift()
                    newLift.reps = lift.reps
                    newLift.datePerformed = lift.datePerformed // use original time for sorting
                    newLift.time = lift.time
                    newLift.weight = lift.weight
                    newLift.owner = newExerciseLog
                    
                    liftCopies.append(newLift)
                }
                
                // Save to datasources
                exerciseLogsAsArray.append(newExerciseLog)
                totalLiftsToDisplay[i] = liftCopies
                i += 1
            }
            
        } else {
            print("ERROR: failed unwrapping exercisesFromWorkout")
            exerciseLogsAsArray = [ExerciseLog]()
        }
    }
    
    private func setupUsingWorkout(withDesign workout: Workout) {
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog to later to later be updated
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = workout
        
        if let orderedSetExercises = workout.exercises {
            
            let exercisesFromWorkout = orderedSetExercises.array as! [Exercise]
            
            // If the workout has any exercises, use them to fetch the last time its exercises were performed (ExerciseLog of each of them). Then make copies of the ExerciseLogItems. These objects are then set to be the dataSource for the tableView
            
            totalLiftsToDisplay = Array(repeating: [Lift](), count: exercisesFromWorkout.count)
            
            var i = 0
            
            // for each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
            for exercise in exercisesFromWorkout {
                
                //make new ExerciseLog
                let newExerciseLog = DatabaseFacade.makeExerciseLog()
                newExerciseLog.exerciseDesign = exercise
                newExerciseLog.usedIn = dataSourceWorkoutLog
                newExerciseLog.datePerformed = Date() as NSDate
                
                var liftCopies = [Lift]()
                
                // Copy values from the most recently performed ExerciseLog to the newly created one
                if let mostRecentExerciseLog = DatabaseFacade.fetchLatestExerciseLog(ofExercise: exercise) {
                    if let mostRecentLifts = mostRecentExerciseLog.lifts {
                        
                        // SortDescriptor
                        let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: false)
                        let sortedRecentLifts = mostRecentLifts.sortedArray(using: [dateSortDescriptor]) as! [Lift]
                        
                        // copy each Lift and add them to the newExerciseLog
                        for l in sortedRecentLifts {
                            let newLift = DatabaseFacade.makeLift()
                            newLift.reps = l.reps
                            newLift.datePerformed = Date() as NSDate
                            newLift.time = l.time
                            newLift.weight = l.weight
                            newLift.owner = newExerciseLog
                            
                            liftCopies.append(newLift)
                        }
                    }
                    exerciseLogsAsArray.append(newExerciseLog)
                }
                
                // Add lifts to the total
                totalLiftsToDisplay[i] = liftCopies
                i += 1
            }
        } else {
            exerciseLogsAsArray = [ExerciseLog]()
        }
    }
    
    // MARK: TableView dataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceWorkoutLog.loggedExercises!.count// uses sections instead of rows to space out cells easily
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exerciseLog = exerciseLogsAsArray[indexPath.section]
        let liftsToDisplay = totalLiftsToDisplay[indexPath.section]
        
//        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseTableViewCell
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseHistoryTableViewCell
        cell = ExerciseHistoryTableViewCell(withExerciseLog: exerciseLog, andIdentifier: cellIdentifier)
//        cell = ExerciseTableViewCell(withExerciseLog: exerciseLog, andLifts: liftsToDisplay, andIdentifier: cellIdentifier)
        cell.owner = self
        
        if let name = exerciseLog.exerciseDesign?.name {
            cell.box.setTitle(name)
        }
        return cell
    }
    
    // MARK: Save methods
    
    func saveWorkout() {
        
        printSummaryOfWorkoutLog()
        
        dataSourceWorkoutLog.dateEnded = Date() as NSDate
        
        // Delete or save
        if countPerformedExercises() == 0 {
            // present error
            let modal = CustomAlertView(type: .error, messageContent: "Bro, you have to actually work out to be able to log an exercise!")
            modal.show(animated: true)
        } else {
            // Save and pop viewController
            deleteUnperformedLifts()
            owner.navigationController?.popViewController(animated: true)
            let modal = CustomAlertView(type: .error, messageContent: "Good job! You performed \(countPerformedExercises()) exercises")
            modal.show(animated: true)
        }
    }
    
    // MARK: Helpers
    
    private func countPerformedExercises() -> Int {
        var performedLifts = 0
        
        if let orderedExercises = dataSourceWorkoutLog.loggedExercises {
            let exerciseSet = orderedExercises.array as! [ExerciseLog]
            for el in exerciseSet {
                if let lifts = el.lifts as? Set<Lift> {
                    for lift in lifts {
                        if lift.hasBeenPerformed { performedLifts += 1 }
                    }
                }
            }
        }
        return performedLifts
    }
    
    // Swap method used when moving cells
    func swapElementsAtIndex(_ firstIndexPath: IndexPath, withObjectAtIndex secondIndexPath: IndexPath
        ) {
        
        let indexA: Int = firstIndexPath.section
        let indexB: Int = secondIndexPath.section
        
        // Swap datasource elements
        let temp = exerciseLogsAsArray[indexA]
        exerciseLogsAsArray[indexA] = exerciseLogsAsArray[indexB]
        exerciseLogsAsArray[indexB] = temp
        
        // Swap the order of the orderedSet
        if let orderedExerciseLogs: NSOrderedSet = dataSourceWorkoutLog.loggedExercises {
            
            var exerciseLogsAsArray = orderedExerciseLogs.array as! [ExerciseLog]
            
            // swap
            let temp = exerciseLogsAsArray[indexA]
            exerciseLogsAsArray[indexA] = exerciseLogsAsArray[indexB]
            exerciseLogsAsArray[indexB] = temp
            
            // put back
            let exerciseLogsAsOrderedeSet = NSOrderedSet(array: exerciseLogsAsArray)
            dataSourceWorkoutLog.loggedExercises = exerciseLogsAsOrderedeSet
        } else {
            print("Error: Could not unwrap orderedExerciseLogs")
        }
    }
    
    // MARK: Delete methods
    
    private func deleteUnperformedLifts() {
        // Deletes all unperformed lifts (that have no datePerformed)
        if let orderedExercises = dataSourceWorkoutLog.loggedExercises {
            let exerciseSet = orderedExercises.array as! [ExerciseLog]
            
            for el in exerciseSet {
                if let lifts = el.lifts as? Set<Lift> {
                    for lift in lifts {
                        if !lift.hasBeenPerformed {
                            DatabaseFacade.delete(lift)
                        }
                    }
                }
            }
        }
    }
    
    func deleteAssosciatedLiftsExerciseLogsAndWorkoutLogs() {
        // Deletes all unperformed lifts
        if let orderedExerciseLogs = dataSourceWorkoutLog.loggedExercises {
            let exerciseLogSet = orderedExerciseLogs.array as! [ExerciseLog]
            for exerciseLog in exerciseLogSet {
                if let lifts = exerciseLog.lifts as? Set<Lift> {
                    for lift in lifts {
                        DatabaseFacade.delete(lift)
                    }
                }
                DatabaseFacade.delete(exerciseLog)
            }
        }
        DatabaseFacade.delete(dataSourceWorkoutLog)
    }
    
    // MARK: Print methods
    
    private func printSummaryOfWorkoutLog() {
        print("\n\nSummary of WL: \(dataSourceWorkoutLog.design!.name)")
        
        guard let orderedLoggedExercises = dataSourceWorkoutLog.loggedExercises else {
            print("ERROR: - No ordered exerciselogs to print")
            return
        }
        // for exercise in dataSourceWorkoutLog.loggedExercises as! Set<ExerciseLog> {
        
        for exercise in orderedLoggedExercises.array as! [ExerciseLog] {
            print("Exercise: ", exercise.exerciseDesign?.name ?? "NA")
            for lift in exercise.lifts as! Set<Lift> {
                var stringToPrint = " - \(lift.reps)"
                stringToPrint.append(lift.hasBeenPerformed ? "(Y)" : "(N)")
                print(stringToPrint)
            }
        }
    }
    
    private func printActualExerciseLogsFromAWorkoutLog() {
        //if let el = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
        if let orderedExerciseLogs = dataSourceWorkoutLog.loggedExercises {
            let el = orderedExerciseLogs.array as! [ExerciseLog]
            
            for exercise in el {
                print("\nExercise: \(String(describing: exercise.exerciseDesign?.name))")
                if let lifts = exercise.lifts {
                    let sortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: true)
                    if let sortedLifts = lifts.sortedArray(using: [sortDescriptor]) as? [Lift]{
                        sortedLifts.oneLinePrint()
                    }
                }
            }
        }
    }
}

