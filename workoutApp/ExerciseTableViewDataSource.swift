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
    var workoutLog: WorkoutLog! // The main datamodel made to be added to core data on save, or deleted on dismiss
    weak var owner: ExerciseTableViewController!
    
    var totalLiftsToDisplay: [[Lift]]! // Each tableViewCell has a "liftsToDisplay" variable to display, this layered array of lifts should store each one of them, and when one of them is changed, it should bubble up the change to this one, which should contain one [Lift] for each tableViewCell. For example if cell 0 is Pull Ups, cell 1 is Hammer Curls, and cell 2 is Dips, then this Dips one should be able to be updated from TotalLiftsToDisplay[2] = liftsToDisplay
    
    // MARK: - Initializers
    
    init(workout: Workout) {
        super.init()
        /* Initializer takes a workout, make a new WorkoutLog of the same kind
         it also makes an ARRAY of NEW ExerciseLog COPIES from core data
         (each of these ExerciseLogs are filled with Lift items),
         based on the previous workout of that kind, and keeps it updated */
        exerciseLogsAsArray = [ExerciseLog]()
        
        // Make new WorkoutLog to later to later be updated
        workoutLog = DatabaseFacade.makeWorkoutLog()
        workoutLog.dateStarted = Date() as NSDate
        
        if let exercisesFromWorkout = workout.exercises as? Set<Exercise> {
            // If the workout has any exercises, use them to fetch the last time its exercises were performed (ExerciseLog of each of them). Then make copies of the ExerciseLogItems. These objects are then set to be the dataSource for the tableView
            
            totalLiftsToDisplay = Array(repeating: [Lift](), count: exercisesFromWorkout.count)
            
            var i = 0
            
            // for each exercise, make a copy of its exerciseLog so that it can be manipulated by user and saved later
            for exercise in exercisesFromWorkout {

                //make new ExerciseLog
                let newExerciseLog = DatabaseFacade.makeExerciseLog()
                newExerciseLog.exerciseDesign = exercise
                newExerciseLog.usedIn = workoutLog
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
        
        // MARK: - testprint
        
        print("after instantiation total is now")
        print(totalLiftsToDisplay)
        
        for e in exerciseLogsAsArray {
            print("exerciseLogsAsArray now has: ", e.exerciseDesign?.name ?? "FAIL")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return currentExerciseLogItems.count // uses sections instead of rows to space out cells easily
        return workoutLog.loggedExercises!.count
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
    
    func deleteTrackedData() {
        // FIXME: - THis method should remove any trace of the workoutLog that was created to serve as a dataSource. Including exerciseLogs and Lifts created.
        
        print("*SHOULD DELETE DATA*")
    }
}

