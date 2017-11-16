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

class ExerciseTableDataSource: NSObject {
    
    private let cellIdentifier: String = "exerciseCell"
    // Data source methods
    var exerciseLogsAsArray: [ExerciseLog]! // each entry represents one tableViewCell. So [0] will be the topmost cell
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    fileprivate var dataSourceWorkoutLog: WorkoutLog! // The workoutLog created to track the currently selected workout. Will be added to core data on save, or deleted on dismiss
    weak var owner: ActiveWorkoutController!
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        // setup data source to use the most recent performance, or the workoutlog if it has not been performed.
        if let lastPerformance = DatabaseFacade.fetchLatestWorkoutLog(ofWorkout: workout) {
            setupUsingWorkoutLog(previousPerformance: lastPerformance)
        } else {
            setupUsingWorkout(withDesign: workout)
        }
    }
    
    // MARK: - Methods
    
    // TableView dataSource methods
    
    // Save methods
    
    /// Saves this inactive workout as
    func saveWorkoutLog() {
        
        guard countPerformedExercises() > 0 else {
            // present error
            let modal = CustomAlertView(type: .error, messageContent: "You have to actually work out to be able to log an exercise!")
            modal.show(animated: true)
            return
        }
        
        dataSourceWorkoutLog.dateEnded = Date() as NSDate
        
        // Save and pop viewController
        updateLatestUseOfMuscle()
        deleteUnperformedLifts()
        
        dataSourceWorkoutLog.markAsLatestperformence()
        owner.navigationController?.popViewController(animated: true)
        let modal = CustomAlertView(type: .message, messageContent: "Good job! You performed \(countPerformedExercises()) Lifts")
        modal.show(animated: true)
        DatabaseFacade.saveContext()
    }
    
    // Swap method used when moving cells
    func swapElementsAtIndex(_ firstIndexPath: IndexPath, withObjectAtIndex secondIndexPath: IndexPath) {
        
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
    
    func deleteAssosciatedLiftsExerciseLogsAndWorkoutLogs() {
        // Deletes all unperformed lifts, exerciseLogs, and then entire WorkoutLog
        DatabaseFacade.delete(dataSourceWorkoutLog)
    }
}

// MARK: - Private helpers

private extension ExerciseTableDataSource {
    
    func updateLatestUseOfMuscle() {
        let musclesUsed = dataSourceWorkoutLog.getMusclesUsed()
        
        for muscle in musclesUsed {
            muscle.performanceCount += 1
            muscle.mostRecentUse = dataSourceWorkoutLog
        }
        DatabaseFacade.saveContext()
    }
    
    // Deletion methods
    
    func deleteUnperformedLifts() {
        // Deletes all unperformed lifts (that have no datePerformed)
        
        guard let orderedExercises = dataSourceWorkoutLog.loggedExercises else { return }
        
        let exercises = orderedExercises.array as! [ExerciseLog]
        
        for exerciseLog in exercises {
            if let lifts = exerciseLog.lifts as? Set<Lift> {
                for lift in lifts {
                    if !lift.hasBeenPerformed {
                        DatabaseFacade.delete(lift)
                    }
                }
            }
        }
    }
    
    // MARK: Setup methods
    
    // Convenience init to allow initialization from a WorkoutLog (latest WorkoutLog)
    func setupUsingWorkoutLog(previousPerformance: WorkoutLog) {

        let previousWorkoutLogDesign = previousPerformance.getDesign()
        
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog and make it identical to the previous one
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog(ofDesign: previousWorkoutLogDesign)
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        
        addPerformedExercises(fromWorkoutLog: previousPerformance)
        addNotYetPerformedExercises(fromWorkoutLog: previousPerformance)
    }
    
    func setupUsingWorkout(withDesign workout: Workout) {
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog to later to later be updated
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog(ofDesign: workout)
        
        let orderedSetExercises = workout.getExercises(includeRetired: false)
        
        if orderedSetExercises.count > 0 {
            // If the workout has any exercises, use them to fetch the last time its exercises were performed (ExerciseLog of each of them). Then make copies of the ExerciseLogItems. These objects are then set to be the dataSource for the tableView
            totalLiftsToDisplay = Array(repeating: [Lift](), count: orderedSetExercises.count)
            
            var i = 0
            // For each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
            for exercise in orderedSetExercises {
                // Make new ExerciseLog
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
                        for lift in sortedRecentLifts {
                            let newLift = DatabaseFacade.makeLift()
                            newLift.reps = lift.reps
                            newLift.datePerformed = Date() as NSDate
                            newLift.time = lift.time
                            newLift.weight = exercise.isWeighted() ? lift.weight : 0
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
    
    private func countPerformedExercises() -> Int {
        guard let orderedExercises = dataSourceWorkoutLog.loggedExercises else { return 0 }
        
        var performedLifts = 0
        
        let exercises = orderedExercises.array as! [ExerciseLog]
        for exerciseLog in exercises {
            if let lifts = exerciseLog.lifts as? Set<Lift> {
                for lift in lifts {
                    performedLifts += lift.hasBeenPerformed ? 1 : 0
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
        
        // loop through previous workoutLogs. append if they are still part of the Workout's design
        for log in previousExerciseLogs {
            if let design = log.exerciseDesign, exercisesInDesign.contains(design) {
                exerciseLogsContainedBothInPreviousAndStillInDesign.append(log)
            } else {
                print("did Contain retired exercise")
            }
        }
        // Make new ExerciseLogs for the resulting exerciseLogs
        totalLiftsToDisplay = Array(repeating: [Lift](), count: exerciseLogsContainedBothInPreviousAndStillInDesign.count)
       
        // for each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
     
        var i = 0
        
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
            let liftCopies = makeCopies(of: sortedRecentLifts, to: newExerciseLog)
            
            // Save to datasources
            exerciseLogsAsArray.append(newExerciseLog)
            totalLiftsToDisplay[i] = liftCopies
            i += 1
        }
    }
    
    private func makeCopies(of lifts: [Lift], to exerciseLog: ExerciseLog) -> [Lift] {
        var liftCopies = [Lift]()
        
        for lift in lifts {
            let newLift = DatabaseFacade.makeLift()
            newLift.reps = lift.reps
            newLift.datePerformed = lift.datePerformed
            newLift.time = lift.time
            newLift.owner = exerciseLog
            newLift.weight = lift.isWeighted() ? lift.weight : 0
            
            liftCopies.append(newLift)
        }
        return liftCopies
    }
    
    /// Adds empty ExerciseLog's for exercises that are in the Workout design, but havent yet been performed
    private func addNotYetPerformedExercises(fromWorkoutLog workoutLog: WorkoutLog) {
        guard let exerciseLogsFromPreviousWorkoutLog = workoutLog.loggedExercises?.set as? Set<ExerciseLog> else { return }
        
        let workoutDesign = workoutLog.design!
        let allUnretiredExercises = Set(workoutDesign.getExercises(includeRetired: false))
        
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

// MARK: - Exetensions: Protocol Conformance

extension ExerciseTableDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // uses sections instead of rows to space out cells easily
        return dataSourceWorkoutLog.loggedExercises!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exerciseLog = exerciseLogsAsArray[indexPath.section]
        let liftsToDisplay = totalLiftsToDisplay[indexPath.section]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseCellForWorkouts
        cell = ExerciseCellForWorkouts(withExerciseLog: exerciseLog, lifts: liftsToDisplay, reuseIdentifier: cellIdentifier)
        cell.accessibilityIdentifier = exerciseLog.getName()
        cell.box.setTitle(exerciseLog.getName())
        cell.owner = self
        
        return cell
    }
}

