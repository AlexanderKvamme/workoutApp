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
        
        // FIXME: - Actually fetch exercises
        
        let fetchRequest = NSFetchRequest<Exercise>(entityName: Entity.Exercise.rawValue)
        fetchRequest.predicate = NSPredicate(format: "musclesUsed == %@", muscle)

        do {
            let result = try DatabaseController.getContext().fetch(fetchRequest)
            
//            print()
//            print()
//            print()
//            print()
//            print()
//            print()
//            print()
//            print("fetchExercises found \(result.count) exercises")
//            print("fetchExercises using muscle received \(result)")
            return result
        } catch let error as NSError {
            print(" error fetching exercises using Muscle: \(error.localizedDescription)")
        }
        return nil
    }
}
