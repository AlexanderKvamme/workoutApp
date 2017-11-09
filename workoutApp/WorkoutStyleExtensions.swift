//
//  WorkoutStyleExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 08/11/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension WorkoutStyle {
    
    func getName() -> String {
        guard let currentName = self.name else {
            self.name = "NO NAME"
            preconditionFailure("Workout style  name")
        }
        
        return currentName
    }
}

