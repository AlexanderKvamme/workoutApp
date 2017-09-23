//
//  Exercise+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 22/09/2017.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var isRetired: Bool
    @NSManaged public var name: String?
    @NSManaged public var loggedInstances: NSSet?
    @NSManaged public var measurementStyle: MeasurementStyle?
    @NSManaged public var musclesUsed: NSSet?
    @NSManaged public var style: ExerciseStyle?
    @NSManaged public var usedInWorkouts: NSSet?

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
