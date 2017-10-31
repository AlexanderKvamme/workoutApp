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

fileprivate final class MeasurementStyles {
    
    // Computed Properties
    
    static var sets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "SETS")
    }
    
    // time
    static var time: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "TIME")
    }
    
    // weighted sets
    static var weightedSets: MeasurementStyle {
        return getOrMakeMeasurementStyle(named: "WEIGHTED SETS")
    }
    
    // Methods
    private static func getOrMakeMeasurementStyle(named name: String) -> MeasurementStyle {
        return DatabaseFacade.getMeasurementStyle(named: name) ?? DatabaseFacade.makeMeasurementStyle(named: name)
    }
}

fileprivate final class Exercises {
    
    // Computed Properties
    
    static var pullUp: Exercise {
        return getOrMakeExercise(named: "PULL UP")
    }
    
    static var bicepFlex: Exercise {
        return getOrMakeExercise(named: "BICEP FLEX")
    }
    
    // Methods
    
    private static func getOrMakeExercise(named name: String) -> Exercise {
        return DatabaseFacade.getExercise(named: name) ??  DatabaseFacade.makeExercise(withName: name, exerciseStyle: ExerciseStyles.normal, muscles: [Muscles.chest], measurementStyle: MeasurementStyles.sets)
    }
}

fileprivate final class ExerciseStyles {
 
    // Computed Properties
    
    static var assisted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "ASSISTED")
    }
    
    static var declined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "DECLINED")
    }
    
    static var explosive: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "EXPLOSIVE")
    }
    
    static var inclined: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INCLINED")
    }
    
    static var inverted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "INVERTED")
    }
    
    static var normal: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "NORMAL")
    }
    
    static var slow: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "SLOW")
    }
    
    static var weighted: ExerciseStyle {
        return getOrMakeExerciseStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private static func getOrMakeExerciseStyle(named name: String) -> ExerciseStyle {
        return DatabaseFacade.getExerciseStyle(named: name) ?? DatabaseFacade.makeExerciseStyle(named: name)
    }
}

/// Used to easily make or get workoutstyles when seeding
fileprivate final class WorkoutStyles {
    
    // Computed Properties
    
    static var cardio: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "CARDIO")
    }
    
    static var dropSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "DROPSET")
    }
    
    static var fun: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "FUN")
    }
    
    static var normal: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "NORMAL")
    }
    
    static var other: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "OTHER")
    }
    
    static var superSet: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "SUPERSET")
    }
    
    static var technique: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "TECHNIQUE")
    }
    
    static var weighted: WorkoutStyle {
        return getOrMakeWorkoutStyle(named: "WEIGHTED")
    }
    
    // Methods
    
    private static func getOrMakeWorkoutStyle(named name: String) -> WorkoutStyle {
        return DatabaseFacade.getWorkoutStyle(named: name) ?? DatabaseFacade.makeWorkoutStyle(named: name)
    }
}

/// Easily accessible muscles for quickly seeding before generating snapshots .etc
fileprivate final class Muscles {
    
    // Computed Properties
    
    static var back: Muscle {
        return getOrMakeMuscle(named: "BACK")
    }
    
    static var legs: Muscle {
        return getOrMakeMuscle(named: "LEGS")
    }
    
    static var other: Muscle {
        return getOrMakeMuscle(named: "OTHER")
    }

    static var glutes: Muscle {
        return getOrMakeMuscle(named: "GLUTES")
    }
    
    static var shoulders: Muscle {
        return getOrMakeMuscle(named: "SHOULDERS")
    }
    
    static var core: Muscle {
        return getOrMakeMuscle(named: "CORE")
    }
    
    static var chest: Muscle {
        return getOrMakeMuscle(named: "CHEST")
    }
    
    static var biceps: Muscle {
        return getOrMakeMuscle(named: "BICEPS")
    }
    
    static var triceps: Muscle {
        return getOrMakeMuscle(named: "TRICEPS")
    }
    
    static var cardio: Muscle {
        return getOrMakeMuscle(named: "CARDIO")
    }
    
    private static func getOrMakeMuscle(named name: String) -> Muscle {
        return DatabaseFacade.getMuscle(named: name) ?? DatabaseFacade.makeMuscle(named: name)
    }
    
}

final class DataSeeder {
    
    // MARK: Properties
    
    private let context: NSManagedObjectContext
    
    // Properties for seeding to Core Data
    private let defaultMuscles = ["OTHER", "BACK", "LEGS", "GLUTES", "SHOULDERS", "CORE", "CHEST", "BICEPS", "TRICEPS", "CARDIO"]
    private let defaultWorkoutStyles = ["NORMAL", "WEIGHTED", "OTHER", "DROP SET", "SUPERSET", "CARDIO", "FUN", "TECHNIQUE"]
    private let defaultExerciseStyles = ["NORMAL", "ASSISTED", "WEIGHTED", "INVERTED", "SLOW", "EXPLOSIVE", "INCLINED", "DECLINED"]
    private let defaultMeasurementStyles = ["TIME", "SETS", "WEIGHTED SETS"] // Add countdown
    
    // MARK: - Initializer
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Methods
    
    public func seedCoreData() {
        seedWithExampleMuscleGroups()
        seedWithExampleWorkoutStyles()
        seedWithExampleExerciseStyles()
        seedWithExampleMeasurementStyles()
        seedWithExampleWarning()
        DatabaseFacade.saveContext()
    }
    
    // FIXME: - seed some cool workouts for snapshotting
    public func seedCoreDataForFastlaneSnapshots() {
        
        // Clear core data
        DataSeeder.clearExercises()
        DataSeeder.clearWorkouts()
        
        // Generate exercises
        DatabaseFacade.makeExercise(withName: "SEED FLEXERS", exerciseStyle: ExerciseStyles.normal, muscles: [Muscles.biceps], measurementStyle: MeasurementStyles.sets)
        
        // Generate workouts
        DatabaseFacade.makeWorkout(withName: "BOOTYBUILDER", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.glutes], exercises: [Exercises.bicepFlex])
        DatabaseFacade.makeWorkout(withName: "HARD CORE", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.core], exercises: [Exercises.pullUp])
        
        DatabaseFacade.makeWorkout(withName: "MUSCLE UP", workoutStyle: WorkoutStyles.technique, muscles: [Muscles.back], exercises: [Exercises.pullUp])
        
        // Generate weighted workout
        let exercisesForPullDay: [Exercise] = [
        DatabaseFacade.makeExercise(withName: "Weighted Pull up", exerciseStyle: ExerciseStyles.weighted, muscles: [Muscles.back], measurementStyle: MeasurementStyles.weightedSets),
        DatabaseFacade.makeExercise(withName: "Pull up", exerciseStyle: ExerciseStyles.explosive, muscles: [Muscles.back], measurementStyle: MeasurementStyles.sets),
        DatabaseFacade.makeExercise(withName: "Australian Pull up", exerciseStyle: ExerciseStyles.weighted, muscles: [Muscles.back], measurementStyle: MeasurementStyles.sets),
        ]
        
        DatabaseFacade.makeWorkout(withName: "PULL DAY", workoutStyle: WorkoutStyles.normal, muscles: [Muscles.back], exercises: exercisesForPullDay)
        
        // Goals
        DatabaseFacade.makeGoal("Live your dream")
        DatabaseFacade.makeGoal("Become extreme")
        
        DatabaseFacade.saveContext()
    }
    
    /// If any new Muscles/Styles are added in code, for example in an update -> seed to core data
    public func update() {
      
        // Muscles
        for muscleName in defaultMuscles {
            if DatabaseFacade.getMuscle(named: muscleName) == nil {
                print("didnt exist so making muscle named \(muscleName)")
                makeMuscle(withName: muscleName)
            }
        }
        
        // Workout Styles
        for styleName in defaultWorkoutStyles {
            if DatabaseFacade.getWorkoutStyle(named: styleName) == nil {
                print("didnt exist so making workoutstyle named \(styleName)")
                makeWorkoutStyle(withName: styleName)
            }
        }
        
        // Exercise Styles
        for styleName in defaultExerciseStyles {
            if DatabaseFacade.getExerciseStyle(named: styleName) == nil {
                print("didnt exist so making exercise named \(styleName)")
                makeExerciseStyle(withName: styleName)
            }
        }
        
        // Measurement Styles
        for measurementStyle in defaultMeasurementStyles {
            if DatabaseFacade.getMeasurementStyle(named: measurementStyle) == nil {
                print("didnt exist so making measurementStyle named \(measurementStyle)")
                makeMeasurementStyle(withName: measurementStyle)
            }
        }
    }
    
    // MARK: - Seed Methods
    
    private func seedWithExampleMuscleGroups() {
        for muscle in defaultMuscles {
            makeMuscle(withName: muscle.uppercased())
        }
    }
    
    private func seedWithExampleWarning() {
        makeWarning(withMessage: "Welcome to the workout app")
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
    
    //  MARK: - Maker methods

    private func makeMuscle(withName name: String) {
        let muscleRecord = DatabaseFacade.makeMuscle()
        muscleRecord.name = name.uppercased()
    }
    
    private func makeWarning(withMessage message: String) {
        let warningRecord = DatabaseFacade.makeWarning()
        warningRecord.dateMade = Date() as NSDate
        warningRecord.message = message
    }
    
    private func makeWorkoutStyle(withName name: String) {
        let workoutStyleRecord = DatabaseFacade.makeWorkoutStyle()
        workoutStyleRecord.name = name.uppercased()
    }
    
    private func makeExerciseStyle(withName name: String) {
        let exerciseStyleRecord = DatabaseFacade.makeExerciseStyle()
        exerciseStyleRecord.name = name.uppercased()
    }
    
    private func makeMeasurementStyle(withName name: String) {
        let measurementStyleRecord = DatabaseFacade.makeMeasurementStyle()
        measurementStyleRecord.name = name.uppercased()
    }
    
    // MARK: - Clear methods
    
    static func clearGoals() {
        guard let currentGoals = DatabaseFacade.fetchGoals() else { return }
        
        for goal in currentGoals {
            DatabaseFacade.delete(goal)
        }
        DatabaseFacade.saveContext()
    }
    
    static func clearWorkouts() {
        
        for workout in DatabaseFacade.fetchAllWorkouts() {
            DatabaseFacade.delete(workout)
        }
        DatabaseFacade.saveContext()
    }
    
    static func clearExercises() {
        for exercise in DatabaseFacade.fetchAllExercises() {
            DatabaseFacade.delete(exercise)
        }
        DatabaseFacade.saveContext()
    }
    
    // MARK: - Print methods
    
    private func printWorkouts() {

        do {
            let request = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
            let allWorkouts = try context.fetch(request)
            
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
            let allMuscles = try context.fetch(request)
            
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
            let allWorkoutStyles = try context.fetch(request)

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
            let allExercises = try context.fetch(request)
            
            print("workout count: ", allExercises.count)
            for exercise in allExercises {
                print()
                print("Name: ", exercise.name ?? "")
                print("Muscle: ", exercise.getMuscles().map({ return $0.name
                }))
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

