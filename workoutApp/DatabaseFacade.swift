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
    
    private init(){}
    
    static func countWorkoutsOfType(ofStyle styleName: String) -> Int {
        
        let style = DatabaseFacade.fetchWorkoutStyle(withName: styleName)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        if let style = style {
            let predicate = NSPredicate(format: "workoutStyle = %@", style)
            fetchRequest.predicate = predicate
            }
        
        do {
            let count = try DatabaseController.getContext().count(for: fetchRequest)
            print("found \(count) workouts with style \(style?.name)")
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Muscle methods
    
    static func fetchMuscleWithName(_ name: String) -> Muscle? {
        let fetchRequest = NSFetchRequest<Muscle>(entityName: Entity.Muscle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            if result.count > 0 {
                return result[0]
            }
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
        }
        print("found no matching muscle")
        return nil
    }
    
    // MARK: - Exercise methods
    
    static func fetchExercises(usingMuscle muscle: Muscle) -> [Exercise]? {
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        fetchRequest.predicate = NSPredicate(format: "musclesUsed == %@", muscle)

        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return nil
    }
    
    static func fetchExercise(named name: String) -> Exercise? {
        
        // TODO: - FIx me up
        
        var e: Exercise? = nil
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Exercise.rawValue)
        let predicate = NSPredicate(format: "name == %@", name)
        fr.predicate = predicate

        do {
            let result = try DatabaseController.getContext().fetch(fr)
            e = result[0] as! Exercise
            print("fetched exercise \(e?.name)")
            
        } catch let error as NSError {
            print("error fetching exercise \(error.localizedDescription)")
        }
        return e
    }
    
    static func makeExercise(withName exerciseName: String, styleName: String, muscleName: String, measurementStyleName: String) -> Exercise {
        
        let newExercise = DatabaseController.createManagedObjectForEntity(.Exercise) as! Exercise
        
        // Fetch correct type, muscle, measurement style from Core Data
        
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let exerciseStyle = DatabaseFacade.getExerciseStyle(named: styleName)
        let measurementStyle = DatabaseFacade.getMeasurementStyle(named: measurementStyleName)
        
        // TODO: - set up the newExercise and save it to database and then show it in the previous screen somehow
        
        newExercise.name = exerciseName
        newExercise.musclesUsed = muscle
        newExercise.style = exerciseStyle
        newExercise.measurementStyle = measurementStyle
        
        DatabaseController.saveContext()
        
        return newExercise
    }
    
    static func makeWorkout(withName workoutName: String, workoutStyleName: String, muscleName: String, exerciseNames: [String]) {
        let workoutRecord = DatabaseController.createManagedObjectForEntity(.Workout) as! Workout
        
        let muscle = DatabaseFacade.getMuscle(named: muscleName)
        let workoutStyle = DatabaseFacade.getWorkoutStyle(named: workoutStyleName)
        
        for exerciseName in exerciseNames {
            if let e = DatabaseFacade.fetchExercise(named: exerciseName){
                workoutRecord.addToExercises(e)
            }
        }
        
        workoutRecord.name = workoutName
        workoutRecord.muscleUsed = muscle
        workoutRecord.workoutStyle = workoutStyle
        print("made workout")
        DatabaseController.saveContext()
    }
    
    // WorkoutStyle methods
    
    static func fetchWorkoutStyle(withName name: String) -> WorkoutStyle? {
        
        var workoutStyle: WorkoutStyle? = nil
        
        let fetchRequest = NSFetchRequest<WorkoutStyle>(entityName: Entity.WorkoutStyle.rawValue)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            workoutStyle = result[0]
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    // MARK: - Getter methods
    
    static func getMuscle(named name: String) -> Muscle? {
        
        var muscle: Muscle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Muscle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            
            fetchRequest.predicate = predicate
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            muscle = result[0] as? Muscle
            
            // TODO: - Får hentet rett muscle. Må hente de andre tingene og så kan jeg lagre den i Core data
            
        } catch let error as NSError {
            print("error fetching \(name): \(error.localizedDescription)")
        }
        return muscle
    }
    
    static func getExerciseStyle(named name: String) -> ExerciseStyle? {
        var exerciseStyle: ExerciseStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.ExerciseStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            exerciseStyle = result[0] as? ExerciseStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return exerciseStyle
    }
    
    static func getWorkoutStyle(named name: String) -> WorkoutStyle? {
        var workoutStyle: WorkoutStyle? = nil
        print("tryna fine workoutStyle named \(name)")
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.WorkoutStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name.uppercased())
            fetchRequest.predicate = predicate
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            print("get wo style got result : ", result)
            workoutStyle = result[0] as? WorkoutStyle
        } catch let error as NSError {
            print("coult not getWorkoutStyle: \(error.localizedDescription)")
        }
        return workoutStyle
    }
    
    static func getMeasurementStyle(named name: String) -> MeasurementStyle? {
        var measurementStyle: MeasurementStyle? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.MeasurementStyle.rawValue)
            let predicate = NSPredicate(format: "name == %@", name)
            fetchRequest.predicate = predicate
            
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            measurementStyle = result[0] as? MeasurementStyle
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return measurementStyle
    }
}
