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

    func getMuscles() -> [Muscle] {

        return [Muscle]()
//        guard var muscles = musclesUsed else { return [Muscle]() }
        
        if let mu = musclesUsed {
            return Array(mu) as! [Muscle]
        }
        print("Exercise had no muscles")
        return [Muscle]()
//        return Array<Muscle>(muscles)
    }
}

