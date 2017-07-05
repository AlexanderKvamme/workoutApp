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
    
    typealias DummyWorkout = (name: String, muscle: String, type: String)
    typealias DummyExercise = (name: String, muscle: String, plannedSets: Int16, type: String)
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - API
    
    public func seedCoreData() {
        seedWithExampleWorkoutsAndExercies()
    }
    
    // MARK: - Seeding
    
    private func seedWithExampleWorkoutsAndExercies() {
        
        var typeString: String = CDModels.workout.type.normal.rawValue
        var muscleString: String = CDModels.workout.type.normal.rawValue
        
        // Workouts
        let backWorkoutDropSet: DummyWorkout = (name: "Back", muscle: "Back", type: "Drop Set")
        let backWorkoutNormal: DummyWorkout = (name: "Back", muscle: "Back", type: "Normal")
        let bicepsTricepsWorkoutDropSet: DummyWorkout = (name: "Biceps and Triceps", muscle: "Arms", type: typeString)
        
        typeString = CDModels.workout.type.normal.rawValue
        muscleString = CDModels.workout.muscle.back.rawValue
        
        // Back - Drop set
        let exercisesForBackDropSet: [DummyExercise] = [
            (name: "Pullup", muscle: muscleString, plannedSets: 4, type: typeString),
            (name: "Backflip", muscle: muscleString, plannedSets: 3, type: typeString),
            (name: "Muscleup", muscle: muscleString, plannedSets: 3, type: typeString),
            (name: "Bridge", muscle: muscleString, plannedSets: 3, type: typeString),
            (name: "Back Extension", muscle: muscleString, plannedSets: 3, type: typeString),
            (name: "Inverted Flies", muscle: muscleString, plannedSets: 3, type: typeString),]
        
        // Back - Normal
        typeString = CDModels.workout.type.normal.rawValue
        muscleString = CDModels.workout.muscle.back.rawValue
        
        let exercisesForBackNormal: [DummyExercise] = [
            (name: "Pull ups", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Australian pull ups", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Chin ups", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Australian chin ups", muscle: muscleString, plannedSets: 1, type: typeString),
            ]
        
        // Arms - Normal
        muscleString = CDModels.workout.muscle.arms.rawValue
        typeString = CDModels.workout.type.dropSet.rawValue
        
        let exercisesForBicepsAndTricepsDropSet: [DummyExercise] = [
            (name: "Bicep Curls", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Hammer Curls", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Fist pumps", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Bicep Pumps", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Biceps Flex", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Chin Ups", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Chin up negatives", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Australian chin ups", muscle: muscleString, plannedSets: 1, type: typeString),
            ]
        
        // Seed into Core Data
        makeWorkout(backWorkoutDropSet, withExercises: exercisesForBackDropSet)
        makeWorkout(bicepsTricepsWorkoutDropSet, withExercises: exercisesForBicepsAndTricepsDropSet)
        makeWorkout(backWorkoutNormal, withExercises: exercisesForBackNormal)

        printWorkouts()
        DatabaseController.saveContext()
    }
    
    // MARK: - Helper Methods
    
    private func makeWorkout(_ workout: DummyWorkout, withExercises exercises: [DummyExercise]) {
        
        // make and add back exercises
        
        let workoutRecord = DatabaseController.createManagedObjectForEntity(.Workout) as! Workout
        workoutRecord.name = workout.name
        workoutRecord.muscle = workout.muscle
        workoutRecord.type = workout.type
        
        for exercise in exercises {
            
            let exerciseRecord = DatabaseController.createManagedObjectForEntity(.Exercise) as! Exercise
            
            exerciseRecord.name = exercise.name
            exerciseRecord.muscle = exercise.muscle
            exerciseRecord.plannedSets = exercise.plannedSets
            exerciseRecord.type = exercise.type
            exerciseRecord.addToUsedInWorkouts(workoutRecord)
            
            // FIXME: - Simulate this exercise having been used
            
            let logItem = DatabaseController.createManagedObjectForEntity(.ExerciseLog) as! ExerciseLog
            if let randomDate = randomDate(daysBack: 10) {
                logItem.datePerformed = randomDate as NSDate
            }
            logItem.design = exerciseRecord
            
            // add lifts this workout
            
            for _ in 0...Int16(arc4random_uniform(UInt32(9))) {
                let lift = DatabaseController.createManagedObjectForEntity(.Lift) as! Lift
                lift.reps = randomRepNumber()
                lift.owner = logItem
                lift.datePerformed = Date() as NSDate
            }
        }
    }
    
    // MARK: - Exercise methods
    
    private func randomRepNumber() -> Int16 {
        let result = Int16(arc4random_uniform(UInt32(99)))
        return result
    }
    
    func randomDate(daysBack: Int)-> Date? {
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
        return randomDate
    }
    
    // MARK: - Print methods
    
    private func printWorkouts() {

        do {
            let request = NSFetchRequest<Workout>(entityName: Entity.Workout.rawValue)
            let allWorkouts = try context.fetch(request)
            
            print("workout count: ", allWorkouts.count)
            
            for workout in allWorkouts {
                print()
                print("Name: ", workout.name ?? "")
                print("----------------------")
                print("Muscle: ", workout.muscle ?? "")
                print("Type: ", workout.type ?? "")
                
                if let exercises = workout.exercises?.allObjects as? [Exercise] {
                    for exercise in exercises {
                        print(" - \(exercise.name ?? "fail")")
                    }
                }
            }
        } catch {
                print("error in printing workouts")
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
                print("Muscle: ", exercise.muscle ?? "")
                print("PlannedSets: ", exercise.plannedSets )
                print("Type: ", exercise.type ?? "")
            }
        } catch {
            print("error in printing exercises")
        }
    }
}

