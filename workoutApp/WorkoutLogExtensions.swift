//
//  WorkoutLogExtensions.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 09/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


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
        let exercises = getExerciseLogs().map { return $0.exerciseDesign }.flatMap { return $0 }.filter({ $0.isRetired == false })
        
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
            let context = DatabaseFacade.context // or however you access context
            self.design = Self.createDefaultWorkoutDesign(context: context)
            print("❌ Falling back to using a default workout.. Cuase it didnt have one...")
            //            preconditionFailure("All workouts must have a design")
            return design!
        }
        
        return design
    }
    
    private static func createDefaultWorkoutDesign(context: NSManagedObjectContext) -> Workout {
        // Check if default workout already exists
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", "Unknown Workout")
        
        if let existingDefault = try? context.fetch(request).first {
            return existingDefault
        }
        
        // Create new default workout
        let defaultWorkout = Workout(context: context)
        defaultWorkout.name = "Unknown Workout"
        // Set other required properties based on your Workout model
        // defaultWorkout.workoutStyle = ...
        
        return defaultWorkout
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


extension WorkoutLog {
    
    // Add this debugging function
    static func auditWorkoutLogsForMissingDesigns() {
        let context = DatabaseFacade.context // or however you access your context
        let request: NSFetchRequest<WorkoutLog> = WorkoutLog.fetchRequest()
        
        do {
            let allWorkoutLogs = try context.fetch(request)
            let logsWithoutDesign = allWorkoutLogs.filter { $0.design == nil }
            
            print("🔍 WORKOUT LOG AUDIT:")
            print("Total workout logs: \(allWorkoutLogs.count)")
            print("Logs without design: \(logsWithoutDesign.count)")
            
            if !logsWithoutDesign.isEmpty {
                print("\n❌ WORKOUT LOGS MISSING DESIGN:")
                for (index, log) in logsWithoutDesign.enumerated() {
                    print("  \(log.getName())")
                    print("  \(index + 1). ID: \(log.objectID)")
//                    print("     Date Started: \(log.dateS ?? "nil")")
//                    print("     Date Ended: \(log.dateEnded ?? "nil")")
                    print("     Logged Exercises: \(log.loggedExercises?.count ?? 0)")
                    print("     ---")
                }
            } else {
                print("✅ All workout logs have designs")
            }
            
        } catch {
            print("Error fetching workout logs: \(error)")
        }
    }
}
