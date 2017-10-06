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
    
    typealias DummyWorkout = (name: String, muscle: Muscle, type: String)
    typealias DummyExercise = (name: String, muscle: Muscle, plannedSets: Int16, type: ExerciseStyle)
    
    // MARK: Properties
    
    // Properties for seeding to Core Data
    private let defaultMuscles = ["OTHER", "BACK", "LEGS", "GLUTES", "SHOULDERS", "CORE", "CHEST", "BICEPS", "TRICEPS", "CARDIO"]
    private let defaultWorkoutStyles = ["NORMAL", "DROP SET", "SUPERSET", "CARDIO", "FUN", "TECHNIQUE"]
    private let defaultExerciseStyles = ["NORMAL", "ASSISTED", "WEIGHTED", "INVERTED", "SLOW", "EXPLOSIVE", "INCLINED", "DECLINED"]
    private let defaultMeasurementStyles = ["TIMER", "SETS"] // Add countdown
    
    private let context: NSManagedObjectContext
    
    // Properties
    
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
    
    /// If any new Muscles/Styles are added in code ie. in an update -> seed to core data
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
        
        // Workout Styles
        for workoutStyle in defaultWorkoutStyles {
            if DatabaseFacade.getWorkoutStyle(named: workoutStyle) == nil {
                print("didnt exist so making muscle named \(workoutStyle)")
                makeWorkoutStyle(withName: workoutStyle)
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

