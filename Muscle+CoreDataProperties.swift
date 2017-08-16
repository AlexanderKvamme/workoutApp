//
//  Muscle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Muscle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Muscle> {
        return NSFetchRequest<Muscle>(entityName: "Muscle")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInExercises: NSSet?
    @NSManaged public var usedInWorkouts: NSSet?

}

// MARK: Generated accessors for usedInExercises
extension Muscle {

    @objc(addUsedInExercisesObject:)
    @NSManaged public func addToUsedInExercises(_ value: Exercise)

    @objc(removeUsedInExercisesObject:)
    @NSManaged public func removeFromUsedInExercises(_ value: Exercise)

    @objc(addUsedInExercises:)
    @NSManaged public func addToUsedInExercises(_ values: NSSet)

    @objc(removeUsedInExercises:)
    @NSManaged public func removeFromUsedInExercises(_ values: NSSet)

}

// MARK: Generated accessors for usedInWorkouts
extension Muscle {

    @objc(addUsedInWorkoutsObject:)
    @NSManaged public func addToUsedInWorkouts(_ value: Workout)

    @objc(removeUsedInWorkoutsObject:)
    @NSManaged public func removeFromUsedInWorkouts(_ value: Workout)

    @objc(addUsedInWorkouts:)
    @NSManaged public func addToUsedInWorkouts(_ values: NSSet)

    @objc(removeUsedInWorkouts:)
    @NSManaged public func removeFromUsedInWorkouts(_ values: NSSet)

}
