//
//  WorkoutStyle+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 08/11/2017.
//
//

import Foundation
import CoreData


extension WorkoutStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutStyle> {
        return NSFetchRequest<WorkoutStyle>(entityName: "WorkoutStyle")
    }

    @NSManaged public var name: String?
    @NSManaged private var workoutLogCount: Int16 // How many workoutLogs of type "WEIGHTED"?
    @NSManaged private var workoutDesignCount: Int16 // How many Workouts (Designs) are "WEIGHTED" Workouts?
    @NSManaged public var usedInWorkouts: NSSet?
    
    // MARK: - Custom Methods
    
    // WorkoutLog count:
    
    public func incrementLogCount() {
        workoutLogCount += 1
    }
    
    public func incrementLogCount(by amount: Int){
        let int16Amount = Int16(amount)
        workoutLogCount += int16Amount
    }
    
    public func decrementLogCount() {
        precondition(workoutLogCount > 1, "Performance count should not be negative")
        workoutLogCount -= 1
    }
    
    public func decrementLogCount(by amount: Int){
        workoutLogCount -= Int16(amount)
    }
    
    public func getPerformanceCount() -> Int {
        return Int(workoutLogCount)
    }
    
    // numberOfWorkoutDesigns
    public func incrementWorkoutDesignCount() {
        workoutDesignCount += 1
    }
    
    public func decrementWorkoutDesignCount() {
        workoutDesignCount -= 1
    }
    
    /// Returns the amount of workout designs that has this style
    public func getWorkoutDesignCount() -> Int{
        return Int(workoutDesignCount)
    }
}

// MARK: Generated accessors for usedInWorkouts
extension WorkoutStyle {

    @objc(addUsedInWorkoutsObject:)
    @NSManaged public func addToUsedInWorkouts(_ value: Workout)

    @objc(removeUsedInWorkoutsObject:)
    @NSManaged public func removeFromUsedInWorkouts(_ value: Workout)

    @objc(addUsedInWorkouts:)
    @NSManaged public func addToUsedInWorkouts(_ values: NSSet)

    @objc(removeUsedInWorkouts:)
    @NSManaged public func removeFromUsedInWorkouts(_ values: NSSet)

}
