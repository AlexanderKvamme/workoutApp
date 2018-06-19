//
//  WorkoutLogExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 09/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation


extension WorkoutLog: Comparable {
    
    // Sortable by date
    public static func < (lhs: WorkoutLog, rhs: WorkoutLog) -> Bool {
        
        return (lhs.dateEnded! as Date) < (rhs.dateEnded! as Date)
    }
}

extension WorkoutLog {
    /// containing muscles get this workoutLog as the latest performance
    func markAsLatestperformence() {
        guard let design = self.design else { return }
        
        design.latestPerformence = self
        
        for muscle in design.getMuscles() {
            muscle.mostRecentUse = self
        }
    }
    
    func getExerciseLogs() -> [ExerciseLog] {
        var arrLoggedExercises = [ExerciseLog]()
        
        guard let loggedExercises = self.loggedExercises else {
            return arrLoggedExercises
        }
        
        arrLoggedExercises = loggedExercises.array as! [ExerciseLog]
        return arrLoggedExercises
    }
    
    func getPerformedExercises(includeRetired: Bool) -> [Exercise] {
        let exercises = getExerciseLogs().map { return $0.exerciseDesign }.compactMap { return $0 }.filter({ $0.isRetired == false })
        
        return exercises
    }
    
    // MARK: Getters
    
    func getName() -> String {
        return getDesign().getName()
    }
    
    func getStyle() -> WorkoutStyle {
        return getDesign().getWorkoutStyle()
    }
    
    func getDesign() -> Workout {
        guard let design = design else {
            preconditionFailure("All workouts must have a design")
        }
        
        return design
    }
    
    func getMusclesUsed() -> [Muscle] {
        var musclesUsed = [Muscle]()
        
        if let muscles = self.design?.getMuscles() {
            musclesUsed = muscles
        }
        return musclesUsed
    }
    
    func getStyleName() -> String {
        return design?.workoutStyle?.name ?? "No Style"
    }
    
    func getTimeSpent() -> String {
        
        guard let end = dateEnded, let start = dateStarted else { return "NA" }
        
        let time = end.timeIntervalSince(start as Date)
        
        return time.asMinimalString()
    }
}
