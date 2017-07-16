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
    
    static func countWorkoutsOfType(ofType type: String) -> Int {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.Workout.rawValue)
        let predicate = NSPredicate(format: "type = %@", type)
        fetchRequest.predicate = predicate
        
        do {
            let count = try DatabaseController.getContext().count(for: fetchRequest)
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
    
    static func makeExercise(withName exerciseName: String, styleName: String, muscleName: String, measurementStyleName: String) -> Exercise {
        print("Gonna make that exercise")
        
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
