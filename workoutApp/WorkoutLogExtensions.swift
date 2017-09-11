//
//  WorkoutLogExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 09/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation


extension WorkoutLog: Comparable {
    public /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func < (lhs: WorkoutLog, rhs: WorkoutLog) -> Bool {
        
        return (lhs.dateEnded! as Date) < (rhs.dateEnded! as Date)
    }

    
    
}
