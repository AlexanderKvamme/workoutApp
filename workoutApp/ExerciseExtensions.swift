//
//  ExerciseExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 17/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension Exercise {
    
    func removeFromAnyWorkouts() {
        DatabaseFacade.removeExerciseFromAnyWorkouts(exercise: self)
    }
    
    func setMuscles(_ muscles: [Muscle]) {
        for muscle in muscles {
            addToMusclesUsed(muscle)
        }
    }
    
    func getName() -> String {
        return name ?? "NO NAME"
    }

    func getMuscles() -> [Muscle] {

        guard let muscles = musclesUsed else {
            fatalError("had no muscles")
        }
        
        return Array(muscles) as! [Muscle]
    }
}

extension Sequence where Iterator.Element == Exercise {
    
    func sortedByName() -> [Exercise] {
        return self.sorted { (a, b) -> Bool in
            guard let ac = a.name?.characters.first, let bc = b.name?.characters.first else { return false }
            return ac < bc
        }
    }
}

