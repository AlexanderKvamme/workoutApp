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
    private let defaultMuscles = ["OTHER", "BACK", "LEGS", "GLUTES", "SHOULDERS", "CORE", "CHEST", "BICEPS", "TRICEPS"]
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
            print("would fetch muscle named \(muscleName)")
            if DatabaseFacade.getMuscle(named: muscleName) == nil {
                print("didnt exist so making muscle named \(muscleName)")
                makeMuscle(withName: muscleName)
            }
        }
        
        // Workout Styles
        for styleName in defaultWorkoutStyles {
            print("would fetch workoutstyle named \(styleName)")
            
            if DatabaseFacade.getWorkoutStyle(named: styleName) == nil {
                print("didnt exist so making workoutstyle named \(styleName)")
                makeWorkoutStyle(withName: styleName)
            }
        }
        
        // Exercise Styles
        for styleName in defaultExerciseStyles {
            print("would fetch exercisestyle named \(styleName)")
            if DatabaseFacade.getExerciseStyle(named: styleName) == nil {
                print("didnt exist so making exercise named \(styleName)")
                makeExerciseStyle(withName: styleName)
            }
        }
        
        // Exercise Styles
        for exerciseStyle in defaultExerciseStyles {
            print("would fetch muscle named \(exerciseStyle)")
            if DatabaseFacade.getMuscle(named: exerciseStyle) == nil {
                print("didnt exist so making muscle named \(exerciseStyle)")
                makeWorkoutStyle(withName: exerciseStyle)
            }
        }
    }
    
    // MARK: - Seed Methods
    
    // NOTE: Give user the option to seed app with example workouts/exercises during onboarding
//    private func seedWithExampleWorkoutsAndExercies() {
//        
//        var typeString: String = CDModels.workout.type.normal.rawValue
//        
//        // Workouts
//        let backMuscle = DatabaseFacade.getMuscle(named: "BACK")!
//        let armsMuscle = DatabaseFacade.getMuscle(named: "ARMS")!
//        let style = DatabaseFacade.getExerciseStyle(named: "Drop Set")!
//        
//        let backWorkoutDropSet: DummyWorkout = (name: "Back", muscle: backMuscle, type: "Drop Set")
//        let backWorkoutNormal: DummyWorkout = (name: "Back", muscle: backMuscle, type: "Normal")
//        let bicepsTricepsWorkoutDropSet: DummyWorkout = (name: "Biceps and Triceps", muscle: armsMuscle, type: typeString)
//        
//        typeString = CDModels.workout.type.normal.rawValue
//        
//        // Back - Drop set
//        let exercisesForBackDropSet: [DummyExercise] = [
//            (name: "Pullup", muscle: backMuscle, plannedSets: 4, type: style),
//            (name: "Backflip", muscle: backMuscle, plannedSets: 3, type: style),
//            (name: "Muscleup", muscle: backMuscle, plannedSets: 3, type: style),
//            (name: "Bridge", muscle: backMuscle, plannedSets: 3, type: style),
//            (name: "Back Extension", muscle: backMuscle, plannedSets: 3, type: style),
//            (name: "Inverted Flies", muscle: backMuscle, plannedSets: 3, type: style),]
//        
//        // Back - Normal
//        typeString = CDModels.workout.type.normal.rawValue
//        
//        let exercisesForBackNormal: [DummyExercise] = [
//            (name: "Pull ups", muscle: backMuscle, plannedSets: 2, type: style),
//            (name: "Australian pull ups", muscle: backMuscle, plannedSets: 2, type: style),
//            (name: "Chin ups", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Australian chin ups", muscle: backMuscle, plannedSets: 1, type: style),
//            ]
//        
//        // Arms - Normal
//        typeString = CDModels.workout.type.dropSet.rawValue
//        
//        let exercisesForBicepsAndTricepsDropSet: [DummyExercise] = [
//            (name: "Bicep Curls", muscle: backMuscle, plannedSets: 2, type: style),
//            (name: "Hammer Curls", muscle: backMuscle, plannedSets: 2, type: style),
//            (name: "Fist pumps", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Bicep Pumps", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Biceps Flex", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Chin Ups", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Chin up negatives", muscle: backMuscle, plannedSets: 1, type: style),
//            (name: "Australian chin ups", muscle: backMuscle, plannedSets: 1, type: style),
//            ]
//        
//        // Seed into Core Data
//        makeWorkout(backWorkoutDropSet, withExercises: exercisesForBackDropSet)
//        makeWorkout(bicepsTricepsWorkoutDropSet, withExercises: exercisesForBicepsAndTricepsDropSet)
//        makeWorkout(backWorkoutNormal, withExercises: exercisesForBackNormal)
//        
//        printWorkouts()
//    }
    
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
    
    // Takes a DummyWorkout (name: String, muscle: Muscle, type: String) and an array of exercises, and creates a new Workout into core data. 
//    private func makeWorkout(_ dummyWorkout: DummyWorkout, withExercises exercises: [DummyExercise]) {
//
//        // Make and add back exercises
//
//        let workoutRecord = DatabaseFacade.makeWorkout()
//        workoutRecord.name = dummyWorkout.name
//        workoutRecord.addToMusclesUsed(dummyWorkout.muscle)
//        workoutRecord.workoutStyle = DatabaseFacade.getWorkoutStyle(named: dummyWorkout.type)
//
//        for exercise in exercises {
//            let exerciseRecord = DatabaseFacade.makeExercise()
//
//            exerciseRecord.name = exercise.name
//            exerciseRecord.style = exercise.type
////            exerciseRecord.musclesUsed = exercise.getMuscles()
//            exerciseRecord.setMuscles(exercise.)
//            exerciseRecord.style = exercise.type
//            exerciseRecord.addToUsedInWorkouts(workoutRecord)
//
//            // Simulate this exercise having been used
//
//            let logItem = DatabaseFacade.makeExerciseLog()
//            if let randomDate = randomDate(daysBack: 10) {
//                logItem.datePerformed = randomDate as NSDate
//            }
//            logItem.exerciseDesign = exerciseRecord
//
//            // add random lifts this workout
//
//            var secondsToAdd = 0 // space out datePerformed to make them sortable by date
//            let maximumAmountOfLiftsToMake = 3
//
//            for _ in 0...Int16(arc4random_uniform(UInt32(maximumAmountOfLiftsToMake))) {
//                let lift = DatabaseFacade.makeLift()
//                lift.reps = randomRepNumber()
//                lift.owner = logItem
//                lift.datePerformed = randomDate(daysBack: 10)
//                lift.hasBeenPerformed = true
//                secondsToAdd += 1
//            }
//        }
//    }

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

