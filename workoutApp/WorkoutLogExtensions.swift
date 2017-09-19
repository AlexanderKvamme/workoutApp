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
    
    func markAsLatestperformence() {
        self.design?.latestPerformence = self
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
        let exercises = getExerciseLogs().map { return $0.exerciseDesign }.flatMap { return $0 }.filter({ $0.isRetired == false })
        
        return exercises
    }
    
    // MARK: Getters
    
    func getName() -> String {
        return design?.name ?? "No Name"
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
