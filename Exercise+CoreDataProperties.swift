//
//  Exercise+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 27/05/2017.
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
    @NSManaged public var usedIn: NSSet?
    @NSManaged public var usedInWorkouts: NSSet?

}

// MARK: Generated accessors for usedIn
extension Exercise {

    @objc(addUsedInObject:)
    @NSManaged public func addToUsedIn(_ value: ExerciseLog)

    @objc(removeUsedInObject:)
    @NSManaged public func removeFromUsedIn(_ value: ExerciseLog)

    @objc(addUsedIn:)
    @NSManaged public func addToUsedIn(_ values: NSSet)

    @objc(removeUsedIn:)
    @NSManaged public func removeFromUsedIn(_ values: NSSet)

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
