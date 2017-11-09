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
    @NSManaged private var performanceCount: Int16
    @NSManaged public var usedInWorkoutsCount: Int16
    @NSManaged public var usedInWorkouts: NSSet?
    
    // MARK: - Custom Methods
    
    public func incrementPerformanceCount() {
        performanceCount += 1
    }
    
    public func decrementPerformanceCount() {
        precondition(performanceCount > 1, "Performance count should not be negative")
        performanceCount -= 1
    }
    
    public func getPerformanceCount() -> Int {
        return Int(performanceCount)
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
