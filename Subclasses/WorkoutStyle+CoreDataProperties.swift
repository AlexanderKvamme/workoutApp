//
//  WorkoutStyle+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 02/05/2025.
//
//

import Foundation
import CoreData


extension WorkoutStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutStyle> {
        return NSFetchRequest<WorkoutStyle>(entityName: "WorkoutStyle")
    }

    @NSManaged public var name: String?
    @NSManaged public var stylePerformanceCount: Int16
    @NSManaged public var workoutDesignCount: Int16
    @NSManaged public var usedInWorkouts: NSSet?

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
