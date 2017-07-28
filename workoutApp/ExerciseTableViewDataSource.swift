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

/*
 Data source for the exercise table view used to display all exercises assosciated with a workout. So you tap a workout, and you enter a tableview with all exercises owned by that workout. This class is the datasource that provides these items.
 */

class ExerciseTableViewDataSource: NSObject, UITableViewDataSource {
    
    let cellIdentifier: String = "exerciseCell"
    weak var owner: ExerciseTableViewController!
    
    // Data source methods
    var exerciseLogsAsArray: [ExerciseLog]! // each entry represents one tableViewCell. So [0] will be the topmost cell
    var dataSourceWorkoutLog: WorkoutLog! // The workoutLog created to track the currently selected workout. Will be added to core data on save, or deleted on dismiss
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        
        // setup data source to use the most recent performance as a foundation, or the workoutlog if it has not been performed.
        if let lastPerformance = DatabaseFacade.fetchLatestWorkoutLog(ofWorkout: workout) {
            setupUsingWorkoutLog(mostRecentPerformance: lastPerformance)
        } else {
            setupUsingWorkout(withDesign: workout)
        }
    }
    
    // convenience init to allow initialization from a WorkoutLog (latest WorkoutLog)
    private func setupUsingWorkoutLog(mostRecentPerformance inputtedWorkoutLog: WorkoutLog) {
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog and make it identical to the previous one
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = inputtedWorkoutLog.design
        
        // FIXME: - copy the exercises of the WorkoutLog provided (which is the last time this workout was performed)
        
        if let exercisesFromInputtedWorkoutLog = inputtedWorkoutLog.loggedExercises as? Set<ExerciseLog> {
            
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
                let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: false)
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
                
                print("\ngonna print copies from : ", exercise.exerciseDesign?.name ?? "BAM")
                for l in liftCopies {
                    print("rep from liftCopies: \(l.reps) - \(l.datePerformed!)")
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
        print("setupUsingWorkoutLog finished")
    }
    
    private func setupUsingWorkout(withDesign workout: Workout) {
        
        print(" - setupUsingWorkout")
        
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog to later to later be updated
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = workout
        
        if let exercisesFromWorkout = workout.exercises as? Set<Exercise> {
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
                } else {
                    print("ERROR: Nothing returned from ExerciseLog fetchRequest")
                }
                // Add lifts to the total
                totalLiftsToDisplay[i] = liftCopies
                i += 1
            }
        } else {
            print("ERROR: Failed unwrapping exercisesFromWorkout")
            exerciseLogsAsArray = [ExerciseLog]()
        }
    }
    
    // MARK: - TableView dataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // uses sections instead of rows to space out cells easily
        return dataSourceWorkoutLog.loggedExercises!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exerciseLog = exerciseLogsAsArray[indexPath.section]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ExerciseTableViewCell
        cell = ExerciseTableViewCell(withExerciseLog: exerciseLog, andIdentifier: cellIdentifier)
        cell.owner = self
        
        if let name = exerciseLog.exerciseDesign?.name {
            cell.box.setTitle(name)
        }
        return cell
    }
    
    // MARK: - Methods
    
    func saveWorkout() {
        print("/n*SAVE*")
        printSummaryOfWorkoutLog()
        
        // set endDate Save to context
        dataSourceWorkoutLog.dateEnded = Date() as NSDate
        
        // Delete or save
        
        if countPerformedExercises() == 0 {
//            // 0 performed lifts. delete entire workoutlog
//            if let loggedExercises = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
//                for exerciseLog in loggedExercises {
//                    DatabaseController.getContext().delete(exerciseLog)
//                }
//            }
//            
//            DatabaseController.getContext().delete(dataSourceWorkoutLog)
            
            // present error.
            let modal = CustomAlertView(type: .error, messageContent: "Bro, you have to actually work out to be able to log an exercise!")
            modal.show(animated: true)
        } else {
        // User has performed lifts - Save and pop viewController
            deleteUnperformedLifts()
            DatabaseController.saveContext()
            owner.navigationController?.popViewController(animated: true)
            let modal = CustomAlertView(type: .error, messageContent: "Good job! You performed \(countPerformedExercises()) exercises")
            modal.show(animated: true)
        }
        
        print("SUMMARY AFTER DELETION")
        printSummaryOfWorkoutLog()
    }
    
    func printActualExerciseLogsFromAWorkoutLog() {
        
        if let el = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
            for exercise in el {
                print("gonna print exercise: \(String(describing: exercise.exerciseDesign?.name))")
                if let lifts = exercise.lifts {
                    let sortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: false)
                    if let sortedLifts = lifts.sortedArray(using: [sortDescriptor]) as? [Lift]{
                        sortedLifts.oneLinePrint()
                    }
                }
            }
        }
    }
    
    func deleteData() {
        // FIXME: - THis method should remove any trace of the workoutLog that was created to serve as a dataSource. Including exerciseLogs and Lifts created.
        print("*SHOULD DELETE DATA - but doesnt*")
        deleteAllLifts()
    }
    
    private func countPerformedExercises() -> Int {
        var performedLifts = 0
        
        // Deletes all unperformed lifts (that have no datePerformed), and returns the count of remaining lifts
        if let exerciseSet = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
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
    
    private func deleteUnperformedLifts() {
        // Deletes all unperformed lifts (that have no datePerformed), and returns the count of remaining lifts
        if let exerciseSet = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
            for el in exerciseSet {
                if let lifts = el.lifts as? Set<Lift> {
                    for lift in lifts {
                        if !lift.hasBeenPerformed {
                            DatabaseController.getContext().delete(lift)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteAllLifts() {
        // Deletes all unperformed lifts (that have no datePerformed), and returns the count of remaining lifts
        if let exerciseLogSet = dataSourceWorkoutLog.loggedExercises as? Set<ExerciseLog> {
            for exerciseLog in exerciseLogSet {
                if let lifts = exerciseLog.lifts as? Set<Lift> {
                    for lift in lifts {
                        DatabaseController.getContext().delete(lift)
                    }
                }
                DatabaseController.getContext().delete(exerciseLog)
            }
        }
        DatabaseController.getContext().delete(dataSourceWorkoutLog)
    }

    
    private func printSummaryOfWorkoutLog() {
        print("\nSummary of WL: \(dataSourceWorkoutLog.design!)")
        for exercise in dataSourceWorkoutLog.loggedExercises as! Set<ExerciseLog> {
            print("Exercise: ", exercise.exerciseDesign?.name)
            for lift in exercise.lifts as! Set<Lift> {
                var stringToPrint = " - \(lift.reps)"
                stringToPrint.append(lift.hasBeenPerformed ? "(Y)" : "(N)")
                print(stringToPrint)
            }
        }
    }
}

