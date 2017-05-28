//
//  DataSeeder.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

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
            (name: "Chins", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Head Bangers", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Australian Chins", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Bicep Pumps", muscle: muscleString, plannedSets: 1, type: typeString),]
        
        // Arms - Normal
        muscleString = CDModels.workout.muscle.arms.rawValue
        typeString = CDModels.workout.type.dropSet.rawValue
        
        let exercisesForBicepsAndTricepsDropSet: [DummyExercise] = [
            (name: "Chins", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Head Bangers", muscle: muscleString, plannedSets: 2, type: typeString),
            (name: "Australian Chins", muscle: muscleString, plannedSets: 1, type: typeString),
            (name: "Bicep Pumps", muscle: muscleString, plannedSets: 1, type: typeString),]
        
        // Seed into Core Data
        makeWorkout(backWorkoutDropSet, withExercises: exercisesForBackDropSet)
        makeWorkout(bicepsTricepsWorkoutDropSet, withExercises: exercisesForBicepsAndTricepsDropSet)
        makeWorkout(backWorkoutNormal, withExercises: exercisesForBackNormal)

        printWorkouts()
        DatabaseController.saveContext()
    }
    
    // Helper Methods
    
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
        }
    }
    
    
    // Print
    
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
