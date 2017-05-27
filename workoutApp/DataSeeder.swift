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
    
    let context: NSManagedObjectContext!
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Seed
    
    public func seed() {
        let workouts = [
            (name: "Biceps/Triceps", muscle: "Arms", type: "Drop Set"),
            (name: "Back", muscle: "Back", type: "Drop Set"),]
   
        let exercises = [(name: "Pullup", muscle: "Back", plannedSets: 4, type: "Drop Set"),
                         (name: "Chins", muscle: "Back", plannedSets: 9, type: "Drop Set"),
                         (name: "Backflip", muscle: "Back", plannedSets: 3, type: "Drop Set"),]
        
        // Make managed objects outta workouts
        for workout in workouts {
            let newRecord = DatabaseController.createManagedObjectForEntity(Entity.WorkoutDesign) as! WorkoutDesign
            newRecord.name = workout.name
            newRecord.muscle = workout.muscle
            newRecord.type = workout.type
        }
        
        // Make managed objects outta exercises
        for exercise in exercises {
            let newRecord = DatabaseController.createManagedObjectForEntity(Entity.ExerciseDesign) as! ExerciseDesign
            
            newRecord.name = exercise.name
            newRecord.muscle = exercise.muscle
            newRecord.plannedSets = Int16(exercise.plannedSets)
            newRecord.type = exercise.type
        }
        
        let workouts = DatabaseController.fetchManagedObjectsForEntity(Entity.WorkoutDesign)
    }
    
    // Seed Workouts
    
    public func seedWorkouts() {
        let workouts = [
            (name: "Biceps/Triceps", muscle: "Arms", type: "Drop Set"),
            (name: "Back", muscle: "Back", type: "Drop Set")]
        
        for workout in workouts {
            let newRecord = DatabaseController.createManagedObjectForEntity(Entity.WorkoutDesign) as! WorkoutDesign
            newRecord.name = workout.name
            newRecord.muscle = workout.muscle
            newRecord.type = workout.type
        }
        DatabaseController.saveContext()
    }
    
    // Seed Exercises
    
    public func seedExercises() {
        let exercises = [(name: "Pullup", muscle: "Back", plannedSets: 4, type: "Drop Set"),
                         (name: "Chins", muscle: "Back", plannedSets: 9, type: "Drop Set")]
        
        for exercise in exercises {
            let newRecord = DatabaseController.createManagedObjectForEntity(Entity.ExerciseDesign) as! ExerciseDesign
            
            newRecord.name = exercise.name
            newRecord.muscle = exercise.muscle
            newRecord.plannedSets = Int16(exercise.plannedSets)
            newRecord.type = exercise.type
        }
        DatabaseController.saveContext()
    }
    
    // Print
    
    public func printWorkouts() {

        do {
            let request = NSFetchRequest<WorkoutDesign>(entityName: "WorkoutDesign")
            
            let allWorkouts = try context.fetch(request)
            
            print("workout count: ", allWorkouts.count)
            for workout in allWorkouts {
//                print("\n\(workout)")
                print()
                print("Name: ", workout.name ?? "")
                print("Muscle: ", workout.muscle ?? "")
                print("Type: ", workout.type ?? "")
            }
            
        } catch {
                print("error in printing workouts")
        }
    }
    
    public func printExercises() {
        do {
            let request = NSFetchRequest<ExerciseDesign>(entityName: Entity.ExerciseDesign.rawValue)
            
            let allExercises = try context.fetch(request)
            
            print("workout count: ", allExercises.count)
            for exercise in allExercises {
//                print("\n\(exercise)")
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
    
    public func seedCoreData() {
        seedWorkouts()
        printWorkouts()
        
        seedExercises()
        printExercises()
    }
}
