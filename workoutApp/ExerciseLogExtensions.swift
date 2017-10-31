//
//  ExerciseLogExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 06/10/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension ExerciseLog {
    func getDesign() -> Exercise {
        guard let design = self.exerciseDesign else {
            fatalError("ExerciseLog had no design")
        }
        return design
    }
    
    func isWeighted() -> Bool {
        return getDesign().isWeighted()
    }
    
    func getName() -> String {
        return getDesign().getName().uppercased()
    }
}
