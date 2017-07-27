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
    var exerciseLogsAsArray: [ExerciseLog]! // when you create NSSet of Exercise, store them as arrays here to let tableView properly arrange them
    var dataSourceWorkoutLog: WorkoutLog! // The main datamodel made to be added to core data on save, or deleted on dismiss
    weak var owner: ExerciseTableViewController!
    
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        
        // PSEUDO
        // - Takes workout
        
        // - Find out if user has performed it before or not
        // - if user has performed it before, use that WorkoutLog and copy it - use copy as datasource
        // - if user has NOT performed it before, use the design layed out
        
        if let lastPerformance = DatabaseFacade.fetchLatestWorkoutLog(ofWorkout: workout) {
            setupUsingWorkoutLog(mostRecentPerformance: lastPerformance)
        } else {
            setupUsingWorkout(withDesign: workout)
        }
        
    } // init
    
    // convenience init to allow initialization from a WorkoutLog (latest WorkoutLog)
    
    private func setupUsingWorkoutLog(mostRecentPerformance inputtedWorkoutLog: WorkoutLog) {
        print("\n\n\nSetupUsingWorkoutLog")
        print("setupUsingWorkoutLog received this log:", inputtedWorkoutLog)
        
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog and make it identical to the previous one
        dataSourceWorkoutLog = DatabaseFacade.makeWorkoutLog()
        dataSourceWorkoutLog.dateStarted = Date() as NSDate
        dataSourceWorkoutLog.design = inputtedWorkoutLog.design
        
        print("workoutLog.design set to ", inputtedWorkoutLog.design ?? "XXX")
        print("inputted had workoutcount: ", inputtedWorkoutLog.loggedExercises?.count ?? "XXX")
        
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
                // FIXME: - This one fetches the latest exercise log of that exercise, but we rather want to copy the exercises from the provided one
                
                // SortDescriptor
                let dateSortDescriptor = NSSortDescriptor(key: "datePerformed", ascending: true)
                let sortedRecentLifts = exercise.lifts?.sortedArray(using: [dateSortDescriptor]) as! [Lift]
                
                // copy each Lift and add them to the newExerciseLog
                for lift in sortedRecentLifts {
                    let newLift = DatabaseFacade.makeLift()
                    newLift.reps = lift.reps
                    newLift.datePerformed = Date() as NSDate
                    newLift.time = lift.time
                    newLift.weight = lift.weight
                    newLift.owner = newExerciseLog
                    
                    print("copied lift had reps: " ,lift.reps)
                    
                    liftCopies.append(newLift)
                }
                
                // Save to datasources
                exerciseLogsAsArray.append(newExerciseLog)
                totalLiftsToDisplay[i] = liftCopies
                i += 1
            }
            
            // FIXME: - add 1,2,3 to each lift, save, go back, and come back, now delete all the 2's and go back and return again. Somehow the wrong workoutLog is being displayed, or its saving the wrong lifts. 
            
            // Changes to the lifts are being displayed, but deleted lifts are not being deleted
            
        } else {
            print("ERROR: failed unwrapping exercisesFromWorkout")
            exerciseLogsAsArray = [ExerciseLog]()
        }
        print("exerciseLogsAsArray ended up as: ", exerciseLogsAsArray)
        print("setupUsingWorkoutLog finished".uppercased())
    }
    
    private func setupUsingWorkout(withDesign workout: Workout) {
        
        print("setupUsingWorkout")
        
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
                        
                        // TODO: - Make sure dates are actually sorted when you get different timestamps
                        
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
                    print("got back a whole bunch of nothing")
                }
                // Add lifts to the total
                totalLiftsToDisplay[i] = liftCopies
                i += 1
            }
        } else {
            print("failed unwrapping exercisesFromWorkout")
            exerciseLogsAsArray = [ExerciseLog]()
        }
    }
    
    
    // MARK: - TableView dataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return currentExerciseLogItems.count // uses sections instead of rows to space out cells easily
        
        // FIXME: - Er noe feil her. denne returnere 8... tror grunnen er at dataSourcen ikke blir reset eller noe
        print("secnumber of sections: ", dataSourceWorkoutLog.loggedExercises!.count)
        
        return dataSourceWorkoutLog.loggedExercises!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("exerciseLogsAsArray count: ", exerciseLogsAsArray.count)
        print("ip: ", indexPath)
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
        print("\nsaveWorkout() received in dataSource")
        dataSourceWorkoutLog.dateEnded = Date() as NSDate
        DatabaseController.saveContext()
        // Make sure workoutLog exists in core data
        
        let workouts = DatabaseController.fetchManagedObjectsForEntity(.WorkoutLog) as! [WorkoutLog]
        print(dataSourceWorkoutLog)
        print("name: ", dataSourceWorkoutLog.design?.name ?? "FAIL: workoutLog.design?.name had no name")
        
    }
    
    func deleteTrackedData() {
        // FIXME: - THis method should remove any trace of the workoutLog that was created to serve as a dataSource. Including exerciseLogs and Lifts created.
        
        print("*SHOULD DELETE DATA*")
    }
}

