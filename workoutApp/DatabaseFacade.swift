//
//  DatabaseFacade.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 28/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData

class DatabaseFacade {
    
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
}
