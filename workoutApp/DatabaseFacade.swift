//
//  DatabaseFacade.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 28/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData
/*
 Facade to provide an easy API to use
 */
final class DatabaseFacade {
    
    private init(){}
    
    static func countWorkoutsOfType(ofStyle styleName: String) -> Int {
        
        let style = DatabaseFacade.fetchWorkoutStyle(withName: styleName)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        if let style = style {
            let predicate = NSPredicate(format: "workoutStyle = %@", style)
            fetchRequest.predicate = predicate
            }
        
        do {
            let count = try DatabaseController.getContext().count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Muscle methods
    
    static func fetchMuscleWithName(_ name: String) -> Muscle? {
        let fetchRequest = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            if result.count > 0 {
                return result[0]
            }
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
        }
        print("found no matching muscle")
        return nil
    }
    
    // MARK: - Exercise methods
    
    static func fetchExercises(usingMuscle muscle: Muscle) -> [Exercise]? {
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        fetchRequest.predicate = NSPredicate(format: "musclesUsed == %@", muscle)

        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - ExerciseLog methods
    
    static func fetchLatestExerciseLog(ofExercise exercise: Exercise) -> ExerciseLog? {
        var resultingExerciseLog: ExerciseLog? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseLog.rawValue)
        let dateDescriptor = NSSortDescriptor(key: "datePerformed", ascending: false)
        let ePredicate = NSPredicate(format: "exerciseDesign == %@", exercise)
        
        fetchRequest.predicate = ePredicate
        fetchRequest.sortDescriptors = [dateDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let res = try DatabaseController.getContext().fetch(fetchRequest)
            resultingExerciseLog = res[0] as? ExerciseLog
        } catch let error as NSError {
            print("failed getting recent exercise")
        }
        return resultingExerciseLog
    }
    
    // MARK: - Maker methods
    
    // Exercise methods
    
    static func fetchExercise(named name: String) -> Exercise? {
        
        var e: Exercise? = nil
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Exercise.rawValue)
        let predicate = NSPredicate(format: "name == %@", name)
        fr.predicate = predicate

        do {
            let result = try DatabaseController.getContext().fetch(fr)
            e = result[0] as? Exercise
        } catch let error as NSError {
            print("error fetching exercise \(error.localizedDescription)")
        }
        return e
    }
    
    static func makeLift() -> Lift {
        let newLift = DatabaseController.createManagedObjectForEntity(.Lift) as! Lift
        return newLift
    }
    
    static func makeExercise(withName exerciseName: String, styleName: String, muscleName: String, measurementStyleName: String) -> Exercise {
        
        let newExercise = DatabaseController.createManagedObjectForEntity(.Exercise) as! Exercise
        
        // Fetch correct type, muscle, measurement style from Core Data
        
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let exerciseStyle = DatabaseFacade.getExerciseStyle(named: styleName)
        let measurementStyle = DatabaseFacade.getMeasurementStyle(named: measurementStyleName)
        
        // TODO: - set up the newExercise and save it to database and then show it in the previous screen somehow
        
        newExercise.name = exerciseName
        newExercise.musclesUsed = muscle
        newExercise.style = exerciseStyle
        newExercise.measurementStyle = measurementStyle
        
        DatabaseController.saveContext()
        
        return newExercise
    }
    
    static func makeExerciseLog() -> ExerciseLog {
        let logItem = DatabaseController.createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
        return logItem
    }
    
    static func makeWorkoutLog() -> WorkoutLog {
        let logItem = DatabaseController.createManagedObjectForEntity(.WorkoutLog) as! WorkoutLog
        return logItem
    }
    
    static func makeWorkout(withName workoutName: String, workoutStyleName: String, muscleName: String, exerciseNames: [String]) {
        
        let workoutRecord = DatabaseController.createManagedObjectForEntity(.Workout) as! Workout
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let workoutStyle = DatabaseFacade.getWorkoutStyle(named: workoutStyleName)
        
        workoutRecord.name = workoutName
        workoutRecord.muscleUsed = muscle
        workoutRecord.workoutStyle = workoutStyle
        
        // Add Exercises to the Workout
        for exerciseName in exerciseNames {
            if let e = DatabaseFacade.fetchExercise(named: exerciseName){
                workoutRecord.addToExercises(e)
            } else {
                print("could not fetch exercise named \(exerciseName)")
            }
        }
        
        // For each exercise make an initial lift, and an initial exercise log of that lift so they can be added to a workoutLog which can then be added to the Workout so that it can be displayed in in BoxTableView/WorkoutTableView and with a detailed view of the dummy lifts as "previous lifts" in the detailed ExerciseTableViewController 
        
        let workoutLog = DatabaseFacade.makeWorkoutLog()
        workoutLog.dateEnded = Date() as NSDate
        workoutLog.dateStarted = Date() as NSDate
        workoutLog.design = workoutRecord
        
        let exercises = workoutRecord.exercises as! Set<Exercise>
        for exercise in exercises {
            // make a log item for this exercise
            let exerciseLog = makeExerciseLog()
            exerciseLog.exerciseDesign = exercise
            
            // make a a lift for the exerciseLog
            let lift = DatabaseFacade.makeLift()
            lift.reps = 0
            lift.datePerformed = Date() as NSDate
            lift.owner = exerciseLog

            workoutLog.addToLoggedExercises(exerciseLog)
        }
        
        workoutRecord.addToLoggedWorkouts(workoutLog)
        DatabaseController.saveContext()
    }
    
    // WorkoutStyle methods
    
    static func fetchWorkoutStyle(withName name: String) -> WorkoutStyle? {
        
        var workoutStyle: WorkoutStyle? = nil
        
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            workoutStyle = result[0]
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // MARK: - Getter methods
    
    static func getMuscle(named name: String) -> Muscle? {
        
        var muscle: Muscle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Muscle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            
            fetchRequest.predicate = predicate
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            muscle = result[0] as? Muscle
            
            // TODO: - Får hentet rett muscle. Må hente de andre tingene og så kan jeg lagre den i Core data
            
        } catch let error as NSError {
            print("error fetching \(name): \(error.localizedDescription)")
        }
        return muscle
    }
    
    static func getExerciseStyle(named name: String) -> ExerciseStyle? {
        var exerciseStyle: ExerciseStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            exerciseStyle = result[0] as? ExerciseStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exerciseStyle
    }
    
    static func getWorkoutStyle(named name: String) -> WorkoutStyle? {
        var workoutStyle: WorkoutStyle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            fetchRequest.predicate = predicate
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            workoutStyle = result[0] as? WorkoutStyle
        } catch let error as NSError {
            print("could not getWorkoutStyle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    static func getMeasurementStyle(named name: String) -> MeasurementStyle? {
        var measurementStyle: MeasurementStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.MeasurementStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            measurementStyle = result[0] as? MeasurementStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return measurementStyle
    }
}
