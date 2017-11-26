//
//  DatabaseFacade.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 28/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

///Facade to provide an easy API to use

final class CoreDataManager {
    
    enum SortingOptions {
        case name
        case mostRecentUse
    }
    
    // MARK: - Properties
    var context: NSManagedObjectContext
    
    init() {
        let persistentContainer = NSPersistentContainer(name: "workoutApp")
        persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            if let error = error {
                print("error: ", error)
            }
        })
        self.context = persistentContainer.viewContext
    }
    
    // Set up with a provided MOC, useful for testing with an in-memory context
    init(providedContext: NSManagedObjectContext) {
    
        guard let storeCoordinator = providedContext.persistentStoreCoordinator else {
            fatalError("had no previous persistentStoreCoordinator")
        }
        
        do {
            let _ = try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch let error {
            print("ERROR: ", error.localizedDescription)
        }
        context = providedContext
        context.persistentStoreCoordinator = storeCoordinator
    }
    
    // Defaults
    
    // TODO: Make sure defaultMuscle and defaultExerciseStyle are not deletebale
    
    var defaultMuscle: Muscle {
        let defaultMuscle = getMuscle(named: "OTHER")!
        return defaultMuscle
    }
    
    var defaultExerciseStyle: ExerciseStyle {
        let style = getExerciseStyle(named: "NORMAL")!
        return style
    }
    
    var defaultWorkoutStyle: WorkoutStyle {
        let style = getWorkoutStyle(named: "NORMAL")!
        return style
    }
    
    var defaultMeasurementStyle: MeasurementStyle {
        let style = getMeasurementStyle(named: "SETS")!
        return style
    }
    
    // MARK: - Methods
    
    // MARK: - Counting methods
    
    func countWorkouts(ofStyle styleName: String) -> Int {
        
        let style = fetchWorkoutStyle(withName: styleName)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        if let style = style {
            let predicate = NSPredicate(format: "workoutStyle = %@", style)
            fetchRequest.predicate = predicate
        }
        
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Delete methods
    
    /// Allow for custom deletion behaviour based on type, while DatabaseFacade exposes this simple abstraction
    func delete(_ objectToDelete : NSManagedObject) {
        
        switch objectToDelete {
        case let workout as Workout:
            deleteWorkout(workout)
        case let workoutLog as WorkoutLog:
            deleteWorkoutLog(workoutLog)
        case let exercise as Exercise:
            retireExercise(exercise)
        default:
            print("Missing specialized deletion method for \(type(of: objectToDelete)). Defaulting to context.delete")
            context.delete(objectToDelete)
        }
        
        saveContext()
    }
    
    /// Cleans out any unfinished(no endDate) workoutLogs.
    func clearUnfininishedWorkoutLogs() {
        
        // Fetch and delete unssaved WorkoutLogs
        let fr = NSFetchRequest<WorkoutLog>(entityName: Entity.WorkoutLog.rawValue)
        let predicate = NSPredicate(format: "dateEnded == nil")
        fr.predicate = predicate
        
        do {
            let results = try context.fetch(fr)
            for r in results {
                delete(r)
            }
        } catch let error as NSError {
            print("Error in clean(): ", error.localizedDescription)
        }
    }
    
    private func retireExercise(_ exercise: Exercise) {
        exercise.isRetired = true
        exercise.removeFromAnyWorkouts()
    }
    
    /// Removes exercise from any Workout using it, so that next workout of its type, this exercise will no longe appear. The exercise will appear in previously performed workouts git(WorkoutLogs) though.
    func removeExerciseFromAnyWorkouts(exercise: Exercise) {
        
        guard let matchingWorkouts = exercise.usedInWorkouts as? Set<Workout> else {
            return
        }
        
        for workout in matchingWorkouts {
            exercise.removeFromUsedInWorkouts(workout)
        }
    }
    
    /// Removes workoutLog, its exerciseLogs
    private func deleteWorkoutLog(_ workoutLogToDelete: WorkoutLog) {
        // mark the predecessing workoutLog as latestPerformence
        
        if let latestPerformence = workoutLogToDelete.getDesign().latestPerformence, latestPerformence === workoutLogToDelete {
            setPreviousWorkoutLogAsLatestPerformence(forWorkout: workoutLogToDelete.getDesign())
        }
        
        // Delete exercises
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
        context.delete(workoutLogToDelete)
    }
    
    private func deleteWorkout(_ workoutToDelete: Workout) {
        guard let loggedWorkouts = workoutToDelete.loggedWorkouts as? Set<WorkoutLog> else {
            preconditionFailure("error unwrapping workoutslog in deleteWorkout")
        }
        
        for workoutLog in loggedWorkouts {
            // NOTE: - This leaves any exercises associated with these workoutLogs still in existance in the persistentStore
            delete(workoutLog)
        }
        context.delete(workoutToDelete)
    }
    
    // MARK: - Make methods
    
    private func createManagedObjectForEntity(_ entity: Entity) -> NSManagedObject? {
        
        var result: NSManagedObject? = nil
        
        let entityDescription = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context)
        if let entityDescription = entityDescription {
            result = NSManagedObject(entity: entityDescription, insertInto: context)
        }
        return result
    }
    
    func makeMuscle() -> Muscle {
        let newMuscle = createManagedObjectForEntity(.Muscle) as! Muscle
        return newMuscle
    }
    
    @discardableResult func makeMuscle(named name: String) -> Muscle {
        let newMuscle = makeMuscle()
        newMuscle.name = name
        return newMuscle
    }
    
    @discardableResult  func makeExercise() -> Exercise {
        let newExercise = createManagedObjectForEntity(.Exercise) as! Exercise
        return newExercise
    }
    
     func makeExerciseStyle() -> ExerciseStyle {
        let newExerciseStyle = createManagedObjectForEntity(.ExerciseStyle) as! ExerciseStyle
        return newExerciseStyle
    }
    
    func makeExerciseStyle(named name: String) -> ExerciseStyle {
        let newStyle = makeExerciseStyle()
        newStyle.name = name
        return newStyle
    }
    
     func makeWorkoutStyle() -> WorkoutStyle {
        let newWorkoutStyle = createManagedObjectForEntity(.WorkoutStyle) as! WorkoutStyle
        return newWorkoutStyle
    }
    
     func makeWorkoutStyle(named name: String) -> WorkoutStyle {
        let newStyle = makeWorkoutStyle()
        newStyle.name = name
        return newStyle
    }
    
     func makeWarning() -> Warning {
        let newWarning = createManagedObjectForEntity(.Warning) as! Warning
        return newWarning
    }
    
     func makeMeasurementStyle() -> MeasurementStyle {
        let newMeasurementStyle = createManagedObjectForEntity(.MeasurementStyle) as! MeasurementStyle
        return newMeasurementStyle
    }
    
     func makeMeasurementStyle(named name: String) -> MeasurementStyle {
        let newStyle = makeMeasurementStyle()
        newStyle.name = name
        
        return newStyle
    }
    
     func makeLift() -> Lift {
        let newLift = createManagedObjectForEntity(.Lift) as! Lift
        return newLift
    }
    
     func makeWorkout() -> Workout {
        let newWorkout = createManagedObjectForEntity(.Workout) as! Workout
        return newWorkout
    }
    
    func makeGoal() -> Goal {
        let newGoal = createManagedObjectForEntity(.Goal) as! Goal
        return newGoal
    }
    
    @discardableResult func makeExercise(withName name: String, exerciseStyle: ExerciseStyle, muscles: [Muscle], measurementStyle: MeasurementStyle) -> Exercise {
        
        let newExercise = makeExercise()
        
        newExercise.name = name.uppercased()
        newExercise.setMuscles(muscles)
        newExercise.style = exerciseStyle
        newExercise.measurementStyle = measurementStyle
        
        return newExercise
    }
    
    func makeExerciseLog() -> ExerciseLog {
        let logItem = createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
        return logItem
    }
    
    func makeExerciseLog(forExercise design: Exercise) -> ExerciseLog {
        let newLog = makeExerciseLog()
        newLog.exerciseDesign = design
        newLog.datePerformed = Date() as NSDate
        
        return newLog
    }
    
    private func makeWorkoutLog() -> WorkoutLog {
        let logItem = createManagedObjectForEntity(.WorkoutLog) as! WorkoutLog
        return logItem
    }
    
     func makeWorkoutLog(ofDesign design: Workout) -> WorkoutLog {
        let log = self.makeWorkoutLog()
        
        log.design = design
        let style = design.getWorkoutStyle()
        
        design.incrementPerformanceCount()
        style.incrementPerformanceCount()
        
        log.dateStarted = Date() as NSDate
        return log
    }
    
     @discardableResult func makeWorkout(withName workoutName: String, workoutStyle: WorkoutStyle, muscles: [Muscle], exercises: [Exercise]) -> Workout {
        let workoutRecord = createManagedObjectForEntity(.Workout) as! Workout
        workoutRecord.setName(workoutName)
        workoutRecord.setInitialWorkoutStyle(workoutStyle)
        workoutRecord.musclesUsed = NSSet(array: muscles)
        workoutStyle.addToUsedInWorkouts(workoutRecord)
        workoutRecord.setExercises(exercises)
        
        return workoutRecord
    }
    
    // MARK: - Fetch/get methods
    
     func fetchManagedObjectsForEntity(_ entity: Entity) -> [NSManagedObject] {
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        
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
     func getExerciseStyles() -> [ExerciseStyle] {
        let exerciseStyles = fetchManagedObjectsForEntity(.ExerciseStyle) as! [ExerciseStyle]
        return exerciseStyles
    }
    
    // fetch Muscles
     func fetchMuscles() -> [Muscle] {
        let muscles = fetchManagedObjectsForEntity(.Muscle) as! [Muscle]
        return muscles
    }
    
     func fetchMuscles(with sortingOption: SortingOptions, ascending: Bool) -> [Muscle] {
        
        var muscles = [Muscle]()
        let fr = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
        
        // Set chosen sortDescriptor
        switch sortingOption{
        case .name:
            fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: ascending)]
        case .mostRecentUse:
            fr.sortDescriptors = [NSSortDescriptor(key: "mostRecentUse.dateEnded", ascending: ascending)]
        }
        
        do {
            let result = try context.fetch(fr)
            muscles = result
        } catch {
            print("error: ", error)
        }
        return muscles
    }
    
    // Fetch all exercises
     func fetchAllExercises() -> [Exercise] {
        var allExercises = [Exercise]()
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        
        do {
            let results = try context.fetch(fetchRequest)
            allExercises = results
        } catch let error as NSError {
            print("Error in fetchMeasurementStyles ", error.localizedDescription)
        }
        
        return allExercises
    }
    
    // Fetch Workouts
     func fetchAllWorkouts() -> [Workout] {
        
        var allWorkouts = [Workout]()
        
        let fetchRequest = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
        
        do {
            let results = try context.fetch(fetchRequest)
            allWorkouts = results
        } catch let error as NSError {
            print("Error in fetchMeasurementStyles ", error.localizedDescription)
        }
        
        return allWorkouts
    }
    
    // Fetch WorkoutStyles
    
     func fetchAllWorkoutStyles() -> [WorkoutStyle] {
        
        var allWorkoutStyles = [WorkoutStyle]()
        
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        
        do {
            let results = try context.fetch(fetchRequest)
            allWorkoutStyles = results
        } catch let error as NSError {
            print("Error in fetchAllWorkoutStyles: ", error.localizedDescription)
        }
        return allWorkoutStyles
    }
    
    // fetch MeasurementStyles
     func fetchMeasurementStyles() -> [MeasurementStyle] {
        
        var measurements = [MeasurementStyle]()
        
        let fetchRequest = NSFetchRequest<MeasurementStyle>(entityName: Entity.MeasurementStyle.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try context.fetch(fetchRequest)
            measurements = results
        } catch let error as NSError {
            print("Error in fetchMeasurementStyles ", error.localizedDescription)
        }
        
        return measurements
    }
    
    // fetch Goals
     func fetchGoals() -> [Goal]? {
        var goals: [Goal]? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Goal.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "dateMade", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try context.fetch(fetchRequest) as! [Goal]
            if result.count > 0 { goals = result }
        } catch let error as NSError{
            print("error in fetchGoals: \(error.localizedDescription)")
        }
        return goals
    }
    
     func getGoals() -> [Goal] {
        return fetchGoals() ?? makeExampleGoals()
    }
    
     private func makeExampleGoals() -> [Goal] {
        return [makeGoal("Hold header to make a goal"),
                makeGoal("Hold goal to delete")]
    }
    
    @discardableResult func makeGoal(_ str: String) -> Goal {
        let newGoal = makeGoal()
        newGoal.dateMade = Date() as NSDate
        newGoal.text = str.uppercased()
        return newGoal
    }
    
     func hasGoals() -> Bool {
        return getGoals().count == 0 ? false : true
    }
    
    // fetch Warnings
     func fetchWarnings() -> [Warning]? {
        var warnings: [Warning]? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Warning.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "dateMade", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let result = try context.fetch(fetchRequest) as! [Warning]
            if result.count > 0 { warnings = result }
        } catch let error as NSError {
            print("Error fetching warnings: \(error.localizedDescription)")
        }
        return warnings
    }
    
    // fetch WorkoutStyle
     func fetchWorkoutStyle(withName name: String) -> WorkoutStyle? {
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
    
    /// Returns all workoutStyles sorted by name
     func fetchWorkoutStyles() -> [WorkoutStyle] {
        
        var workoutStyles = [WorkoutStyle]()
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let result = try context.fetch(fetchRequest)
            workoutStyles = result as [WorkoutStyle]
        } catch let error as NSError {
            print("Error in fetchWorkoutStyles: \(error.localizedDescription)")
        }
        return workoutStyles
    }
    
    // get ExerciseStyle
     func getExerciseStyle(named name: String) -> ExerciseStyle? {
        var exerciseStyle: ExerciseStyle? = nil
        
        // Execute Fetchrequest
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseStyle.rawValue)
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            exerciseStyle = result.first as? ExerciseStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exerciseStyle
    }
    
    /// All ExerciseStyles sorted by name
     func getAllExerciseStyles() -> [ExerciseStyle] {
        var exerciseStyles = [ExerciseStyle]()
        
        // Make FetchRequest
        let fetchRequest = NSFetchRequest<ExerciseStyle>(entityName: Entity.ExerciseStyle.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Execute fetchRequest
        do {
            let result = try context.fetch(fetchRequest)
            exerciseStyles = result
        } catch let error as NSError {
            print("Error in getExerciseStyles: ", error.localizedDescription)
        }
        return exerciseStyles
    }
    
    // get WorkoutStyle
     func getWorkoutStyle(named name: String) -> WorkoutStyle? {
        
        var workoutStyle: WorkoutStyle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                workoutStyle = result.first as? WorkoutStyle
            }
        } catch let error as NSError {
            print("could not getWorkoutStyle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // get MeasurementStyle
     func getMeasurementStyle(named name: String) -> MeasurementStyle? {
        var measurementStyle: MeasurementStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.MeasurementStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            fetchRequest.predicate = predicate
            
            let result = try context.fetch(fetchRequest)
            measurementStyle = result.first as? MeasurementStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return measurementStyle
    }
    
    // fetch Exercise
     func getExercise(named name: String) -> Exercise? {
        
        var exercise: Exercise? = nil
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Exercise.rawValue)
        let predicate = NSPredicate(format: "name == %@", name.uppercased())
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.fetch(fetchRequest)
            exercise = result.first as? Exercise
        } catch let error as NSError {
            print("error fetching exercise \(error.localizedDescription)")
        }
        return exercise
    }
    
    // get Muscle
    func getMuscle(named name: String) -> Muscle? {
        
        var muscle: Muscle? = nil
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Muscle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            
            fetchRequest.predicate = predicate
            let result = try context.fetch(fetchRequest)
            muscle = result.first as? Muscle
        } catch let error as NSError {
            print("error fetching \(name): \(error.localizedDescription)")
        }
        return muscle
    }
    
     func fetchExercises(containing muscle: Muscle) -> [Exercise]? {
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        let predicate1 = NSPredicate(format: "musclesUsed CONTAINS %@", muscle)
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
    
     func fetchLatestExerciseLog(ofExercise exercise: Exercise) -> ExerciseLog? {
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
    
     func fetchLatestWorkoutLog(ofWorkout workout: Workout) -> WorkoutLog? {
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
    
    func fetchAllWorkoutLogs() -> [WorkoutLog] {
        
        var result: [WorkoutLog] = [WorkoutLog]()
        
        let fetchRequest = NSFetchRequest<WorkoutLog>(entityName: Entity.WorkoutLog.rawValue)
        let dateSorter = NSSortDescriptor(key: "dateEnded", ascending: false)
        fetchRequest.sortDescriptors = [dateSorter]
        
        do {
            let results = try context.fetch(fetchRequest)
            result = results
        } catch let error as NSError {
            print("Error fetching all workoutlogs: \(error.localizedDescription)")
        }
        return result
    }
    
    // MARK: - Save methods
     func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("error saving to persistentContainers viewContext")
        }
    }
}

// MARK: Helpers

fileprivate extension CoreDataManager {
    /// when deleting a workoutLog, you would want to make the previous performance the new "latestPerformance" of its kind.
    func setPreviousWorkoutLogAsLatestPerformence(forWorkout workout: Workout) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutLog.rawValue)
        fetchRequest.predicate = NSPredicate(format: "design == %@", workout)
        fetchRequest.fetchLimit = 2
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateEnded", ascending: false)]
        
        do {
            let result = try context.fetch(fetchRequest) as! [WorkoutLog]
            if result.count > 2 {
                result[1].markAsLatestperformence()
            }
        } catch let error as NSError {
            print("error in deleteWorkoutLog: \(error.localizedDescription)")
        }
    }
}

