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
    
    // Defaults
    
    // TODO: Make sure defaultMuscle and defaultExerciseStyle are not deletebale
    
    static var defaultMuscle: Muscle = {
        // return undefined
        let defaultMuscle = getMuscle(named: "UNDEFINED")!
        return defaultMuscle
    }()
    
    static var defaultExerciseStyle: ExerciseStyle = {
        let style = getExerciseStyle(named: "NORMAL")!
        return style
    }()

    static var defaultWorkoutStyle: WorkoutStyle = {
        let style = getWorkoutStyle(named: "NORMAL")!
        return style
    }()
    
    static var defaultMeasurementStyle: MeasurementStyle = {
        let style = getMeasurementStyle(named: "SETS")!
        return style
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
    
    /// Allow for custom deletion behaviour based on type, while DatabaseFacade exposes this simple abstraction
    static func delete(_ objectToDelete : NSManagedObject) {
        
        switch objectToDelete {
        case let workoutLog as WorkoutLog:
            deleteWorkoutLog(workoutLog)
        case let exercise as Exercise:
            retireExercise(exercise)
        default:
            persistentContainer.viewContext.delete(objectToDelete)
        }
        
        saveContext()
    }
    
    private static func retireExercise(_ exercise: Exercise) {
        exercise.isRetired = true
        
        // For any workout contaning this exercise. Remove it
        exercise.removeFromAnyWorkouts()
    }
    
    /// Removes exercise from any Workout using it, so that next workout of its type, this exercise will no longe appear. The exercise will appear in previously performed workouts git(WorkoutLogs) though.
    static func removeExerciseFromAnyWorkouts(exercise: Exercise) {
        
        guard let matchingWorkouts = exercise.usedInWorkouts as? Set<Workout> else {
            return
        }

        for workout in matchingWorkouts {
            exercise.removeFromUsedInWorkouts(workout)
        }
    }
    
    static func deleteWorkoutLog(_ workoutLogToDelete: WorkoutLog) {
        // loop through its Exerciselogs, delete their lifts, then delete exerciselog and then delete workoutLog
        
        // mark the predecessing workoutLog as latestPerformence
        if let workoutDesign = workoutLogToDelete.design, let latestPerformence = workoutDesign.latestPerformence {
            if latestPerformence === workoutLogToDelete {
                setPreviousWorkoutLogAsLatestPerformence(forWorkout: workoutDesign)
            }
        }
        
        let orderedExerciseLogs: NSMutableOrderedSet = workoutLogToDelete.mutableOrderedSetValue(forKey: "loggedExercises")
        
        let exerciseLogsToDelete = orderedExerciseLogs.array
        
        for exerciseLog in exerciseLogsToDelete {
            
            guard let exerciseLog = exerciseLog as? ExerciseLog else {
                print("Error: exerciseLog could not be cast to ExerciseLog")
                return
            }
            
            guard let liftsTodelete = exerciseLog.lifts as? Set<Lift> else {
                print("Error unwrapping lifts in deleteWorkoutLog")
                return
            }
            
            for lift in liftsTodelete {
                delete(lift)
            }
            delete(exerciseLog)
        }
        persistentContainer.viewContext.delete(workoutLogToDelete)
    }
    
    static func deleteWorkout(_ workoutToDelete: Workout) {
        guard let loggedWorkouts = workoutToDelete.loggedWorkouts as? Set<WorkoutLog> else {
            print("error unwrapping workoutslog in deleteWorkout")
            return
        }
        
        for workoutLog in loggedWorkouts {
            // NOTE: - This leaves any exercises associated with these workoutLogs still in existance in the persistentStore
            delete(workoutLog)
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
    
    static func makeWarning() -> Warning {
        let newWarning = createManagedObjectForEntity(.Warning) as! Warning
        return newWarning
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
    
    static func makeGoal() -> Goal {
        let newGoal = createManagedObjectForEntity(.Goal) as! Goal
        return newGoal
    }
    
    static func makeExercise(withName exerciseName: String, styleName: String, muscleName: String, measurementStyleName: String) -> Exercise {
        
        let newExercise = makeExercise()
        
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
    
    static func makeExercise(withName name: String, exerciseStyle: ExerciseStyle, muscle: Muscle, measurementStyle: MeasurementStyle) -> Exercise {
        
        let newExercise = makeExercise()
        
        newExercise.name = name
        newExercise.musclesUsed = muscle
        newExercise.style = exerciseStyle
        newExercise.measurementStyle = measurementStyle
        
        return newExercise
    }
    
    static func makeExerciseLog() -> ExerciseLog {
        let logItem = createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
        return logItem
    }
    
    static func makeExerciseLog(forExercise design: Exercise) -> ExerciseLog {
        let newLog = makeExerciseLog()
        newLog.exerciseDesign = design
        newLog.datePerformed = Date() as NSDate

        return newLog
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
    }
    
    // DatabaseFacade.makeWorkout(withName: workoutName, workoutStyleName: workoutStyleName, muscleName: muscleName, exerciss: currentlySelectedExercises)
    static func makeWorkout(withName workoutName: String, workoutStyleName: String, muscleName: String, exercises: [Exercise]) {
        
        let workoutRecord = createManagedObjectForEntity(.Workout) as! Workout
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let workoutStyle = DatabaseFacade.getWorkoutStyle(named: workoutStyleName)
        
        workoutRecord.name = workoutName
        workoutRecord.muscleUsed = muscle
        workoutRecord.workoutStyle = workoutStyle
        
        // Add Exercises to the Workout
        for exercise in exercises {
            workoutRecord.addToExercises(exercise)
        }
    }
    
    // MARK: - Fetch/get methods
    
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
    
    // fetch MeasurementStyles
    static func fetchMeasurementStyles() -> [MeasurementStyle] {
        let measurements = fetchManagedObjectsForEntity(.MeasurementStyle) as! [MeasurementStyle]
        return measurements
    }
    
    // fetch Goals
    static func fetchGoals() -> [Goal]? {
        var goals: [Goal]? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Goal.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "dateMade", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try DatabaseFacade.context.fetch(fetchRequest) as! [Goal]
            if result.count > 0 { goals = result }
        } catch let error as NSError{
            print("error in fetchGoals: \(error.localizedDescription)")
        }
        return goals
    }
    
    // fetch Warnings
    static func fetchWarnings() -> [Warning]? {
        var warnings: [Warning]? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Warning.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "dateMade", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try DatabaseFacade.context.fetch(fetchRequest) as! [Warning]
            if result.count > 0 { warnings = result }
        } catch let error as NSError {
            print("Error fetching warnings: \(error.localizedDescription)")
        }
        return warnings
    }
    
    // fetch WorkoutStyle
    static func fetchWorkoutStyle(withName name: String) -> WorkoutStyle? {
        var workoutStyle: WorkoutStyle? = nil
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let result = try context.fetch(fetchRequest)
            workoutStyle = result[0]
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // get ExerciseStyle
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
    
    // get WorkoutStyle
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
    
    // get MeasurementStyle
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
    
    // fetch Exercise
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
    
    // get Muscle
    static func getMuscle(named name: String) -> Muscle? {
        
        let name = name.uppercased()
        
        var muscle: Muscle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Muscle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            muscle = result.first as? Muscle
        } catch let error as NSError {
            print("error fetching \(name): \(error.localizedDescription)")
        }
        return muscle
    }
    
    static func fetchExercises(usingMuscle muscle: Muscle) -> [Exercise]? {
        
        // FIXME: - fix
        print("Would fetch every exercise")
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        let predicate1 = NSPredicate(format: "musclesUsed == %@", muscle)
        let predicate2 = NSPredicate(format: "isRetired == false")
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        fetchRequest.predicate = andPredicate
        
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
            print("Error getting recent exercise: \(error.localizedDescription)")
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
            print("Error fetching all workoutlogs: \(error.localizedDescription)")
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

// MARK: Helpers

fileprivate extension DatabaseFacade {
    
    /// when deleting a workoutLog, you would want to make the previous performance the new "latestPerformance" of its kind.
    static func setPreviousWorkoutLogAsLatestPerformence(forWorkout workout: Workout) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutLog.rawValue)
        fetchRequest.predicate = NSPredicate(format: "design == %@", workout)
        fetchRequest.fetchLimit = 2
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateEnded", ascending: false)]
        
        do {
            let result = try DatabaseFacade.context.fetch(fetchRequest) as! [WorkoutLog]
            if result.count > 2 {
                result[1].markAsLatestperformence()
            }
        } catch let error as NSError {
            print("error in deleteWorkoutLog: \(error.localizedDescription)")
        }
    }
}

