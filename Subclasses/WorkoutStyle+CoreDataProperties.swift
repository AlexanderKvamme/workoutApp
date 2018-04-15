//
//  WorkoutStyle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander K on 15/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
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
