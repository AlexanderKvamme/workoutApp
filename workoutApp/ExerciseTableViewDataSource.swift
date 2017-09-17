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

class ExerciseTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let cellIdentifier: String = "exerciseCell"
    
    // Data source methods
    var exerciseLogsAsArray: [ExerciseLog]! // each entry represents one tableViewCell. So [0] will be the topmost cell
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    fileprivate var dataSourceWorkoutLog: WorkoutLog! // The workoutLog created to track the currently selected workout. Will be added to core data on save, or deleted on dismiss
    weak var owner: ExerciseTableViewController!
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        // setup data source to use the most recent performance, or the workoutlog if it has not been performed.
        if let lastPerformance = DatabaseFacade.fetchLatestWorkoutLog(ofWorkout: workout) {
            print("setupUsingWorkoutLog")
            setupUsingWorkoutLog(previousPerformance: lastPerformance)
        } else {
            print("setupUsingWorkout")
            setupUsingWorkout(withDesign: workout)
        }
    }
    
    // MARK: - Methods
    
    // TableView dataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceWorkoutLog.loggedExercises!.count// uses sections instead of rows to space out cells easily
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exerciseLog = exerciseLogsAsArray[indexPath.section]
        let liftsToDisplay = totalLiftsToDisplay[indexPath.section]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseTableViewCell
        
        //cell = ExerciseTableViewCell(withExerciseLog: exerciseLog, andLifts: liftsToDisplay, andIdentifier: cellIdentifier)
        cell = ExerciseTableViewCell(withExerciseLog: exerciseLog, lifts: liftsToDisplay, reuseIdentifier: cellIdentifier)
        cell.owner = self
        
        if let name = exerciseLog.exerciseDesign?.name {
            cell.box.setTitle(name)
        }
        return cell
    }
    
    // Save methods
    
    func saveWorkout() {
        
        dataSourceWorkoutLog.dateEnded = Date() as NSDate
        
        // Delete or save
        if countPerformedExercises() == 0 {
            // present error
            let modal = CustomAlertView(type: .error, messageContent: "Bro, you have to actually work out to be able to log an exercise!")
            modal.show(animated: true)
        } else {
            // Save and pop viewController
            
            // Save as most recent use of current muscle
            updateLatestUseOfMuscle()
            deleteUnperformedLifts()
            dataSourceWorkoutLog.markAsLatestperformence()
            owner.navigationController?.popViewController(animated: true)
            let modal = CustomAlertView(type: .error, messageContent: "Good job! You performed \(countPerformedExercises()) exercises")
            modal.show(animated: true)
        }
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
}

// MARK: - Private helpers

private extension ExerciseTableViewDataSource {
    
    func updateLatestUseOfMuscle() {
        if let muscleUsed = dataSourceWorkoutLog.design?.muscleUsed {
            muscleUsed.mostRecentUse = dataSourceWorkoutLog
        }
    }
    
    // MARK: Print methods
    
    private func printSummaryOfWorkoutLog() {
        print("\n\nSummary of WL: \(String(describing: dataSourceWorkoutLog.design!.name))")
        
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
    
    // Deletion methods
    
    func deleteUnperformedLifts() {
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
    
    // MARK: Setup methods
    
    // Convenience init to allow initialization from a WorkoutLog (latest WorkoutLog)
    func setupUsingWorkoutLog(previousPerformance: WorkoutLog) {
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog and make it identical to the previous one
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = previousPerformance.design
        
        addPerformedExercises(fromWorkoutLog: previousPerformance)
        addNotYetPerformedExercises(fromWorkoutLog: previousPerformance)
    }
    
    func setupUsingWorkout(withDesign workout: Workout) {
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
    
    // MARK: Helpers
    
    func countPerformedExercises() -> Int {
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
    
    /// Copies the workoutLogs from the previous performance, but only the ones that are currently part of that Workout's list of Exercises
    private func addPerformedExercises(fromWorkoutLog previousLog: WorkoutLog) {
        let exercisesInDesign = previousLog.design!.getExercises(includeRetired: false)
        let previousExerciseLogs = previousLog.getExerciseLogs()
        var exerciseLogsContainedBothInPreviousAndStillInDesign = [ExerciseLog]()
        
        // loop through all workoutLogs from the previous workout, only append if they are still part of the Workout's design
        for log in previousExerciseLogs {
            if let design = log.exerciseDesign {
                if exercisesInDesign.contains(design) {
                    exerciseLogsContainedBothInPreviousAndStillInDesign.append(log)
                }
            }
        }
        // Make new ExerciseLogs for the resulting exerciseLogs
        totalLiftsToDisplay = Array(repeating: [Lift](), count: exerciseLogsContainedBothInPreviousAndStillInDesign.count)
        var i = 0
        
        // for each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
        for exerciseLog in exerciseLogsContainedBothInPreviousAndStillInDesign {
            // make new ExerciseLog
            let newExerciseLog = DatabaseFacade.makeExerciseLog()
            newExerciseLog.exerciseDesign = exerciseLog.exerciseDesign
            newExerciseLog.usedIn = dataSourceWorkoutLog
            newExerciseLog.datePerformed = Date() as NSDate
            
            // Copy values from the most recently performed ExerciseLog to the newly created one
            
            // SortDescriptor
            let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: true)
            let sortedRecentLifts = exerciseLog.lifts?.sortedArray(using: [dateSortDescriptor]) as! [Lift]
            
            // copy each Lift and add them to the newExerciseLog
            var liftCopies = [Lift]()
            
            for lift in sortedRecentLifts {
                let newLift = DatabaseFacade.makeLift()
                newLift.reps = lift.reps
                newLift.datePerformed = lift.datePerformed
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
    }
    
    /// Adds empty ExerciseLog's for exercises that are in the Workout desig, but havent yet been performed
    private func addNotYetPerformedExercises(fromWorkoutLog workoutLog: WorkoutLog) {
        
        let workoutDesign = workoutLog.design!
        let allUnretiredExercises = Set(workoutDesign.getExercises(includeRetired: false))
        
        if let exerciseLogsFromPreviousWorkoutLog = workoutLog.loggedExercises?.set as? Set<ExerciseLog> {
            var performedExercises = Set<Exercise>()
            
            for log in exerciseLogsFromPreviousWorkoutLog {
                if let exercise = log.exerciseDesign {
                    performedExercises.insert(exercise)
                }
            }
            
            let exercisesToAdd = allUnretiredExercises.subtracting(performedExercises)
            
            for exercise in exercisesToAdd {
                let newLog = DatabaseFacade.makeExerciseLog(forExercise: exercise)
                newLog.usedIn = dataSourceWorkoutLog
                
                exerciseLogsAsArray.append(newLog)
                totalLiftsToDisplay.append([Lift]())
            }
        }
    }
}

