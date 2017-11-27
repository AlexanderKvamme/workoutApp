//
//  DataSeeder.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

/*
 Used to make some example workouts, exercises, and exerciseLogs when the app is freshly installed
 */

final class DataSeeder {
    
    // MARK: Properties
    private let coreDataManager: CoreDataManager
    
    // Quick access for seeding
    lazy var muscles = Muscles(coreDataManager: self.coreDataManager)
    lazy var exerciseStyle = ExerciseStyles(coreDataManager: self.coreDataManager)
    lazy var measurementStyles = MeasurementStyles(coreDataManager: self.coreDataManager)
    lazy var exercises = Exercises(coreDataManager: self.coreDataManager)
    lazy var workoutStyles = WorkoutStyles(coreDataManager: self.coreDataManager)
    
    // Properties for seeding to Core Data
    private let defaultMuscles = ["OTHER", "BACK", "LEGS", "GLUTES", "SHOULDERS", "CORE", "CHEST", "BICEPS", "TRICEPS", "CARDIO"]
    private let defaultWorkoutStyles = ["NORMAL", "WEIGHTED", "OTHER", "DROP SET", "SUPERSET", "CARDIO", "FUN", "TECHNIQUE"]
    private let defaultExerciseStyles = ["NORMAL", "ASSISTED", "WEIGHTED", "INVERTED", "SLOW", "EXPLOSIVE", "INCLINED", "DECLINED"]
    private let defaultMeasurementStyles = ["TIME", "SETS", "WEIGHTED SETS"] // Add countdown
    
    // MARK: - Initializer
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Methods
    
    public func seedCoreData() {
        seedWithExampleMuscleGroups()
        seedWithExampleWorkoutStyles()
        seedWithExampleExerciseStyles()
        seedWithExampleMeasurementStyles()
        coreDataManager.saveContext()
    }
    
    /// Clears out persistent store to make room for snapshottable exercises only
    public func seedCoreDataForFastlaneSnapshots() {
        
        
        // FIXME: - Maybe not needed as i use in memory store for testing now
        // Clear core data
        
//        let dataSeeder = DataSeeder(coreDataManager: coreDataManager)
//        dataSeeder.clear(entity: Entity.WorkoutLog)
//        dataSeeder.clear(entity: Entity.Exercise)
//        dataSeeder.clear(entity: Entity.Workout)
//        dataSeeder.clear(entity: Entity.Goal)
//        dataSeeder.resetCounts()
        
        // Quick access to static variables
        let muscles = Muscles(coreDataManager: coreDataManager)
        let exercises = Exercises(coreDataManager: coreDataManager)
        let exerciseStyles = ExerciseStyles(coreDataManager: coreDataManager)
        let measurementStyles = MeasurementStyles(coreDataManager: coreDataManager)
        let workoutStyles = WorkoutStyles(coreDataManager: coreDataManager)
        
        // Generate exercises
        coreDataManager.makeExercise(withName: "SEED FLEXERS", exerciseStyle: exerciseStyles.normal, muscles: [muscles.biceps], measurementStyle: measurementStyles.sets)
        
        // Generate workouts
        coreDataManager.makeWorkout(withName: "BOOTYBUILDER", workoutStyle: workoutStyles.normal, muscles: [muscles.glutes], exercises: [exercises.bicepFlex])
        coreDataManager.makeWorkout(withName: "HARD CORE", workoutStyle: workoutStyles.normal, muscles: [muscles.core], exercises: [exercises.pullUp])
        coreDataManager.makeWorkout(withName: "MUSCLE UP", workoutStyle: workoutStyles.technique, muscles: [muscles.back], exercises: [exercises.pullUp])
        
        // Generate weighted workout
        let exercisesForPullDay: [Exercise] = [
            coreDataManager.makeExercise(withName: "WEIGHTED PULL UP", exerciseStyle: exerciseStyles.weighted, muscles: [muscles.back], measurementStyle: measurementStyles.weightedSets),
            coreDataManager.makeExercise(withName: "PULL UP", exerciseStyle: exerciseStyles.explosive, muscles: [muscles.back], measurementStyle: measurementStyles.sets),
            coreDataManager.makeExercise(withName: "AUSTRALIAN PULL UP", exerciseStyle: exerciseStyles.weighted, muscles: [muscles.back], measurementStyle: measurementStyles.sets),
            ]
        coreDataManager.makeWorkout(withName: "PULL DAY", workoutStyle: workoutStyles.normal, muscles: [muscles.back], exercises: exercisesForPullDay)
        
        // Goals
        coreDataManager.makeGoal("Set your goals")
        coreDataManager.makeGoal("CRUSH your goals")
        
        coreDataManager.saveContext()
    }
    
    /// If any new Muscles/Styles are added in code, for example in an update -> seed to core data
    public func update() {
        
        // Muscles
        for muscleName in defaultMuscles {
            if coreDataManager.getMuscle(named: muscleName.uppercased()) == nil {
                print("didnt exist in context so making muscle named \(muscleName)")
                makeMuscle(withName: muscleName.uppercased())
            }
        }
        
        // Workout Styles
        for workoutStyleName in defaultWorkoutStyles {
            if coreDataManager.getWorkoutStyle(named: workoutStyleName) == nil {
                print("didnt exist in context so making workoutstyle named \(workoutStyleName)")
                makeWorkoutStyle(withName: workoutStyleName)
            }
        }
        
        // Exercise Styles
        for exerciseStyleName in defaultExerciseStyles {
            if coreDataManager.getExerciseStyle(named: exerciseStyleName) == nil {
                print("didnt exist in context so making exercise named \(exerciseStyleName)")
                makeExerciseStyle(withName: exerciseStyleName)
            }
        }
        
        // Measurement Styles
        for measurementStyle in defaultMeasurementStyles {
            if coreDataManager.getMeasurementStyle(named: measurementStyle) == nil {
                print("didnt exist in context so making measurementStyle named \(measurementStyle)")
                makeMeasurementStyle(withName: measurementStyle)
            }
        }
    }
    
    // MARK: - Seed Methods
    
    private func seedWithExampleMuscleGroups() {
        for muscle in defaultMuscles {
            if coreDataManager.getMuscle(named: muscle) == nil {
                makeMuscle(withName: muscle.uppercased())
            }
        }
    }
    
    private func seedWithExampleWarning() {
        makeWarning(withMessage: "Welcome to the Hone")
    }
    
    private func seedWithExampleWorkoutStyles() {
        for name in defaultWorkoutStyles {
            makeWorkoutStyle(withName: name)
        }
        printWorkoutStyles()
    }
    
    private func seedWithExampleExerciseStyles() {
        for exerciseStyleName in defaultExerciseStyles {
            makeExerciseStyle(withName: exerciseStyleName)
        }
    }
    
    private func seedWithExampleMeasurementStyles() {
        for measurementStyleName in defaultMeasurementStyles {
            makeMeasurementStyle(withName: measurementStyleName)
        }
    }
    
    // MARK: - Public seeder methods
    
    // MARK: - Helper methods
    @discardableResult public func makeLongWorkout(coreDataManager: CoreDataManager) -> Workout {
        
        let exerciseHolder = Exercises(coreDataManager: coreDataManager)
        let exercises = [exerciseHolder.weightedPullUp, exerciseHolder.pullUp, exerciseHolder.WMSPullUp, exerciseHolder.chestToBar, exerciseHolder.assistedChestToBar, exerciseHolder.negativeMuscleUp, exerciseHolder.bicepFlex, exerciseHolder.tricepsFlex]
        
        let newLongWorkout = coreDataManager.makeWorkout(withName: "LONG WORKOUT", workoutStyle: WorkoutStyles(coreDataManager: coreDataManager).normal, muscles: [Muscles(coreDataManager: coreDataManager).back], exercises: exercises)
        coreDataManager.saveContext()
        
        return newLongWorkout
    }
    
    //  MARK: - Maker methods
    
    private func makeMuscle(withName name: String) {
        let muscleRecord = coreDataManager.makeMuscle()
        muscleRecord.name = name.uppercased()
    }
    
    private func makeWarning(withMessage message: String) {
        let warningRecord = coreDataManager.makeWarning()
        warningRecord.dateMade = Date() as NSDate
        warningRecord.message = message
    }
    
    private func makeWorkoutStyle(withName name: String) {
        guard coreDataManager.getWorkoutStyle(named: name.uppercased()) == nil else {
            return
        }
        let workoutStyleRecord = coreDataManager.makeWorkoutStyle()
        workoutStyleRecord.name = name.uppercased()
    }
    
    private func makeExerciseStyle(withName name: String) {
        guard coreDataManager.getExerciseStyle(named: name.uppercased()) == nil else {
            return
        }
        let exerciseStyleRecord = coreDataManager.makeExerciseStyle()
        exerciseStyleRecord.name = name.uppercased()
    }
    
    private func makeMeasurementStyle(withName name: String) {
        guard coreDataManager.getMeasurementStyle(named: name.uppercased()) == nil else {
            return
        }
        let measurementStyleRecord = coreDataManager.makeMeasurementStyle()
        measurementStyleRecord.name = name.uppercased()
    }
    
    // MARK: - Clear methods
    
    /// Completely removes all instances of a type from The persistence store
    func clear(entity: Entity) {
        print("clearing: ", entity.rawValue)
        // Create the delete request for the specified entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Perform the delete
        do {
            try coreDataManager.context.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
        coreDataManager.saveContext()
    }
    
    /// Method resets static counts of design and performances, and is needed batchDelete does not run NSManagedObject.prepareForDelete() on each individual object
    func resetCounts() {
        for workoutStyle in coreDataManager.fetchWorkoutStyles() {
            workoutStyle.resetCount()
        }
    }
    
    // MARK: - Print methods
    
    private func printWorkouts() {
        
        do {
            let request = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
            let allWorkouts = try coreDataManager.context.fetch(request)
            
            print("workout count: ", allWorkouts.count)
            
            for workout in allWorkouts {
                print("\nName: ", workout.name ?? "")
                print("----------------------")
                
                if let exercises = workout.exercises?.array as? [Exercise] {
                    for exercise in exercises {
                        print(" - \(exercise.name ?? "fail")")
                    }
                }
            }
        } catch {
            print("error in printing workouts")
        }
    }
    
    private func printMuscles() {
        do {
            let request = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
            let allMuscles = try coreDataManager.context.fetch(request)
            
            print("Muscle count: ", allMuscles.count)
            print()
            
            for muscle in allMuscles {
                print("Name: ", muscle.name ?? "")
            }
            print("----------------------")
        } catch {
            print("error in printing Muscles")
        }
    }
    
    private func printWorkoutStyles() {
        do {
            let request = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
            let allWorkoutStyles = try coreDataManager.context.fetch(request)
            
            print("WorkoutStyle count: ", allWorkoutStyles.count)
            for style in allWorkoutStyles {
                print("Name: ", style.name ?? "")
            }
        } catch {
            print("error in printing workoutStyles")
        }
    }
    
    private func printExercises() {
        do {
            let request = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
            let allExercises = try coreDataManager.context.fetch(request)
            
            print("workout count: ", allExercises.count)
            for exercise in allExercises {
                print()
                print("Name: ", exercise.name ?? "")
                print("Muscle: ", exercise.getMuscles().map({ return $0.name }))
                print("Type: ", exercise.style?.name ?? "")
            }
        } catch {
            print("error in printing exercises")
        }
    }
    
    // MARK: - Exercise Helper Methods
    
    private func randomRepNumber() -> Int16 {
        let result = Int16(arc4random_uniform(UInt32(99)))
        return result
    }
    
    private func randomDate(daysBack: Int)-> NSDate? {
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(UInt32(23))
        let minute = arc4random_uniform(UInt32(59))
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = Int(day - 1)
        offsetComponents.hour = Int(hour)
        offsetComponents.minute = Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate as NSDate?
    }
}

