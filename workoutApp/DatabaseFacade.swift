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
    
    private init(){} // Disable instance creation
    
    // MARK: - Properties
    
    static var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "workoutApp")
        persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            if let error = error {
                print("error: ", error)
            }
        })
        return persistentContainer
    }()
    
    static var context: NSManagedObjectContext = {
        return DatabaseFacade.persistentContainer.viewContext
    }()
    
    // MARK: - Methods
    
    // MARK: - Counting methods
    
    static func countWorkouts(ofStyle styleName: String) -> Int {
        
        let style = DatabaseFacade.fetchWorkoutStyle(withName: styleName)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        if let style = style {
            let predicate = NSPredicate(format: "workoutStyle = %@", style)
            fetchRequest.predicate = predicate
            }
        
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    static func countWorkoutLogs(ofStyle styleName: String) -> Int {
        
        let style = DatabaseFacade.fetchWorkoutStyle(withName: styleName)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutLog.rawValue)
        if let style = style {
            let predicate = NSPredicate(format: "design.workoutStyle = %@", style)
            fetchRequest.predicate = predicate
        }
        
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Delete methods
    
    static func delete(_ objectToDelete : NSManagedObject) {
        persistentContainer.viewContext.delete(objectToDelete)
    }
    
    static func deleteWorkoutLog(_ workoutLogToDelete: WorkoutLog) {
        // loop throuhg its Exerciselogs, delete their lifts, then delete exerciselog and then delete workoutLog
        guard let exerciseLogsToDelete = workoutLogToDelete.loggedExercises as? Set<ExerciseLog> else {
            print("error unwrapping logged exercises in deleteWorkoutLog")
            return
        }
        
        for exerciseLog in exerciseLogsToDelete {
            
            guard let liftsTodelete = exerciseLog.lifts as? Set<Lift> else {
                print("error unwrapping lifts in deleteWorkoutLog")
                return
            }
            
            for lift in liftsTodelete {
                delete(lift)
            }
            delete(exerciseLog)
        }
        delete(workoutLogToDelete)
    }
    
    static func deleteWorkout(_ workoutToDelete: Workout) {
        guard let loggedWorkouts = workoutToDelete.loggedWorkouts as? Set<WorkoutLog> else {
            print("error unwrapping workoutslog in deleteWorkout")
            return
        }
        print("loggedWorkouts: \(loggedWorkouts.count) would be deleted")
        
        for workoutLog in loggedWorkouts {
            delete(workoutLog)
            // NOTE: - This leaves any exercises assosciated with these workoutLogs still in existance in the persistentStore
        }
        delete(workoutToDelete)
    }
    
    // MARK: - Make methods
    
    private static func createManagedObjectForEntity(_ entity: Entity) -> NSManagedObject? {
        
        let context = persistentContainer.viewContext
        var result: NSManagedObject? = nil
        
        let entityDescription = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context)
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: context)
        }
        return result
    }
    
    static func makeMuscle() -> Muscle {
        let newMuscle = createManagedObjectForEntity(.Muscle) as! Muscle
        return newMuscle
    }
    
    static func makeExercise() -> Exercise {
        let newExercise = createManagedObjectForEntity(.Exercise) as! Exercise
        return newExercise
    }
    
    static func makeExerciseStyle() -> ExerciseStyle {
        let newExerciseStyle = createManagedObjectForEntity(.ExerciseStyle) as! ExerciseStyle
        return newExerciseStyle
    }
    
    static func makeWorkoutStyle() -> WorkoutStyle {
        let newWorkoutStyle = createManagedObjectForEntity(.WorkoutStyle) as! WorkoutStyle
        return newWorkoutStyle
    }
    
    static func makeMeasurementStyle() -> MeasurementStyle {
        let newMeasurementStyle = createManagedObjectForEntity(.MeasurementStyle) as! MeasurementStyle
        return newMeasurementStyle
    }
    
    static func makeLift() -> Lift {
        let newLift = createManagedObjectForEntity(.Lift) as! Lift
        return newLift
    }
    
    static func makeWorkout() -> Workout {
        let newWorkout = createManagedObjectForEntity(.Workout) as! Workout
        return newWorkout
    }
    
    static func makeExercise(withName exerciseName: String, styleName: String, muscleName: String, measurementStyleName: String) -> Exercise {
        
        let newExercise = createManagedObjectForEntity(.Exercise) as! Exercise
        
        // Fetch correct type, muscle, measurement style from Core Data
        
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let exerciseStyle = DatabaseFacade.getExerciseStyle(named: styleName)
        let measurementStyle = DatabaseFacade.getMeasurementStyle(named: measurementStyleName)
        
        newExercise.name = exerciseName
        newExercise.musclesUsed = muscle
        newExercise.style = exerciseStyle
        newExercise.measurementStyle = measurementStyle
        
        return newExercise
    }
    
    static func makeExerciseLog() -> ExerciseLog {
        let logItem = createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
        return logItem
    }
    
    static func makeWorkoutLog() -> WorkoutLog {
        let logItem = createManagedObjectForEntity(.WorkoutLog) as! WorkoutLog
        return logItem
    }
    
    static func makeWorkout(withName workoutName: String, workoutStyleName: String, muscleName: String, exerciseNames: [String]) {
        
        let workoutRecord = createManagedObjectForEntity(.Workout) as! Workout
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
    }
    
    // MARK: - Fetch methods
    
    static func fetchManagedObjectsForEntity(_ entity: Entity) -> [NSManagedObject] {
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let context = persistentContainer.viewContext
        var result = [NSManagedObject]()
        
        do {
            let objects = try context.fetch(fetchRequest)
            if let objects = objects as? [NSManagedObject] {
                result = objects
            }
        } catch {
            print("unable to fetch objects for entity \(entity)")
        }
        return result
    }
    
    // fetch Exercise Style
    static func fetchExerciseStyles() -> [ExerciseStyle] {
        let exerciseStyles = fetchManagedObjectsForEntity(.ExerciseStyle) as! [ExerciseStyle]
        return exerciseStyles
    }
    
    // fetch Muscles
    static func fetchMuscles() -> [Muscle] {
        let muscles = fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
        return muscles
    }
    
    // fetch WorkoutStyle
    static func fetchWorkoutStyle(withName name: String) -> WorkoutStyle? {
        var workoutStyle: WorkoutStyle? = nil
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            // Execute Fetch
            let result = try context.fetch(fetchRequest)
            workoutStyle = result[0]
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // getMuscle
    static func getMuscle(named name: String) -> Muscle? {
        var muscle: Muscle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Muscle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            muscle = result[0] as? Muscle
            
        } catch let error as NSError {
            print("error fetching \(name): \(error.localizedDescription)")
        }
        return muscle
    }
    
    // getExerciseStyle
    static func getExerciseStyle(named name: String) -> ExerciseStyle? {
        var exerciseStyle: ExerciseStyle? = nil
        do {
            // Execute Fetchrequest
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try context.fetch(fetchRequest)
            exerciseStyle = result[0] as? ExerciseStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exerciseStyle
    }
    
    // getWorkoutStyle
    static func getWorkoutStyle(named name: String) -> WorkoutStyle? {
        var workoutStyle: WorkoutStyle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            workoutStyle = result[0] as? WorkoutStyle
        } catch let error as NSError {
            print("could not getWorkoutStyle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // getMeasurementStyle
    static func getMeasurementStyle(named name: String) -> MeasurementStyle? {
        var measurementStyle: MeasurementStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.MeasurementStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try context.fetch(fetchRequest)
            measurementStyle = result[0] as? MeasurementStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return measurementStyle
    }
    
    static func fetchExercise(named name: String) -> Exercise? {
        
        var exercise: Exercise? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Exercise.rawValue)
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            exercise = result[0] as? Exercise
        } catch let error as NSError {
            print("error fetching exercise \(error.localizedDescription)")
        }
        return exercise
    }
    
    static func fetchMuscleWithName(_ name: String) -> Muscle? {
        let fetchRequest = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                return result[0]
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        print("found no matching muscle")
        return nil
    }
    
    static func fetchExercises(usingMuscle muscle: Muscle) -> [Exercise]? {
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        fetchRequest.predicate = NSPredicate(format: "musclesUsed == %@", muscle)
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return nil
    }
    
    static func fetchLatestExerciseLog(ofExercise exercise: Exercise) -> ExerciseLog? {
        var resultingExerciseLog: ExerciseLog? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseLog.rawValue)
        let dateDescriptor = NSSortDescriptor(key: "datePerformed", ascending: false)
        let ePredicate = NSPredicate(format: "exerciseDesign == %@", exercise)
        
        fetchRequest.predicate = ePredicate
        fetchRequest.sortDescriptors = [dateDescriptor]
        fetchRequest.fetchLimit = 1
        
        do {
            let res = try context.fetch(fetchRequest)
            resultingExerciseLog = res[0] as? ExerciseLog
        } catch let error as NSError {
            print("failed getting recent exercise: \(error.localizedDescription)")
        }
        return resultingExerciseLog
    }
    
    static func fetchLatestWorkoutLog(ofWorkout workout: Workout) -> WorkoutLog? {
        var workoutLog: WorkoutLog? = nil
        
        // make fetchrequest for most recently performed workout of provided type
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutLog.rawValue)
        let stylePredicate = NSPredicate(format: "design == %@", workout)
        let dateSorter = NSSortDescriptor(key: "dateEnded", ascending: false)
        fetchRequest.predicate = stylePredicate
        fetchRequest.sortDescriptors = [dateSorter]
        fetchRequest.fetchLimit = 1
        
        do {
            if let result = try context.fetch(fetchRequest) as? [WorkoutLog] {
                if result.count > 0 {
                    workoutLog = result[0]
                }
            }
        } catch let error as NSError {
            print("i got error: \(error.localizedDescription)")
        }
        return workoutLog
    }
    
    static func fetchAllWorkoutLogs() -> [WorkoutLog]? {
        
        var result: [WorkoutLog]? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutLog.rawValue)
        let dateSorter = NSSortDescriptor(key: "dateEnded", ascending: false)
        fetchRequest.sortDescriptors = [dateSorter]
        
        do {
            result = try persistentContainer.viewContext.fetch(fetchRequest) as? [WorkoutLog]
        } catch let error as NSError {
            print("error fetching all workoutlogs: \(error.localizedDescription)")
        }
        return result
    }
    
    // MARK: - Save methods
    static func saveContext() {
        
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("error saving to persistentContainers viewContext")
            }
        } else {
            print("no changes to save")
        }
    }
}

