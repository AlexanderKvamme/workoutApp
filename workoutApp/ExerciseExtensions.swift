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

//        return [Muscle]()
        guard let muscles = musclesUsed else {
            fatalError("had no muscles")
        }
        
        return Array(muscles) as! [Muscle]
        
        
//        return Array<Muscle>(muscles)
        
        
        
    }
}

