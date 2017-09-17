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
        print("would remove from any workouts")
        
        DatabaseFacade.removeExerciseFromAnyWorkouts(exercise: self)
    }
}

