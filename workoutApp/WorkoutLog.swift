//
//  WorkoutLog.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 31/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

extension WorkoutLog {
    func getLiftCount() -> Int {
        var count = 0
        for e in self.loggedExercises?.array as! [ExerciseLog] {
            count += e.lifts?.count ?? 0
        }
        return count
    }
}
