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
    
    
    
    // MARK: - Custom Methods
    
    // WorkoutLog count:
    
    // Incrementers
    
    public func incrementPerformanceCount() {
        stylePerformanceCount += 1
    }
    
    public func incrementPerformanceCount(by amount: Int){
        let int16Amount = Int16(amount)
        stylePerformanceCount += int16Amount
    }
    
    // Decrementers
    
    public func decrementPerformanceCount() {
        print("styleperformance was: ", stylePerformanceCount)
        precondition(stylePerformanceCount > 0, "Performance count should not be negative")
        stylePerformanceCount -= 1
    }
    
    public func decrementPerformanceCount(by amount: Int){
        stylePerformanceCount -= Int16(amount)
    }
    
    public func getPerformanceCount() -> Int {
        return Int(stylePerformanceCount)
    }
    
    // numberOfWorkoutDesigns
    public func incrementWorkoutDesignCount() {
        workoutDesignCount += 1
    }
    
    public func decrementWorkoutDesignCount() {
        workoutDesignCount -= 1
    }
    
    /// Returns the amount of workout designs that has this style
    public func getWorkoutDesignCount() -> Int {
        return Int(workoutDesignCount)
    }
    
    public func resetCount() {
        workoutDesignCount = 0
        stylePerformanceCount = 0
    }
}

