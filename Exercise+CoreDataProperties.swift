//
//  Exercise+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var muscle: String?
    @NSManaged public var name: String?
    @NSManaged public var plannedSets: Int16
    @NSManaged public var type: String?
    @NSManaged public var attribute: NSObject?
    @NSManaged public var attribute1: NSObject?
    @NSManaged public var attribute2: NSObject?
    @NSManaged public var attribute3: NSObject?
    @NSManaged public var loggedInstances: NSSet?
    @NSManaged public var musclesUsed: NSSet?
    @NSManaged public var usedInWorkouts: NSSet?
    @NSManaged public var style: ExerciseStyle?

}

// MARK: Generated accessors for loggedInstances
extension Exercise {

    @objc(addLoggedInstancesObject:)
    @NSManaged public func addToLoggedInstances(_ value: ExerciseLog)

    @objc(removeLoggedInstancesObject:)
    @NSManaged public func removeFromLoggedInstances(_ value: ExerciseLog)

    @objc(addLoggedInstances:)
    @NSManaged public func addToLoggedInstances(_ values: NSSet)

    @objc(removeLoggedInstances:)
    @NSManaged public func removeFromLoggedInstances(_ values: NSSet)

}

// MARK: Generated accessors for musclesUsed
extension Exercise {

    @objc(addMusclesUsedObject:)
    @NSManaged public func addToMusclesUsed(_ value: Muscle)

    @objc(removeMusclesUsedObject:)
    @NSManaged public func removeFromMusclesUsed(_ value: Muscle)

    @objc(addMusclesUsed:)
    @NSManaged public func addToMusclesUsed(_ values: NSSet)

    @objc(removeMusclesUsed:)
    @NSManaged public func removeFromMusclesUsed(_ values: NSSet)

}

// MARK: Generated accessors for usedInWorkouts
extension Exercise {

    @objc(addUsedInWorkoutsObject:)
    @NSManaged public func addToUsedInWorkouts(_ value: Workout)

    @objc(removeUsedInWorkoutsObject:)
    @NSManaged public func removeFromUsedInWorkouts(_ value: Workout)

    @objc(addUsedInWorkouts:)
    @NSManaged public func addToUsedInWorkouts(_ values: NSSet)

    @objc(removeUsedInWorkouts:)
    @NSManaged public func removeFromUsedInWorkouts(_ values: NSSet)

}
