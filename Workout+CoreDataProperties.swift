//
//  Workout+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Workout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workout> {
        return NSFetchRequest<Workout>(entityName: "Workout")
    }

    @NSManaged public var muscle: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var exercises: NSSet?
    @NSManaged public var loggedWorkouts: NSSet?

}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

// MARK: Generated accessors for loggedWorkouts
extension Workout {

    @objc(addLoggedWorkoutsObject:)
    @NSManaged public func addToLoggedWorkouts(_ value: WorkoutLog)

    @objc(removeLoggedWorkoutsObject:)
    @NSManaged public func removeFromLoggedWorkouts(_ value: WorkoutLog)

    @objc(addLoggedWorkouts:)
    @NSManaged public func addToLoggedWorkouts(_ values: NSSet)

    @objc(removeLoggedWorkouts:)
    @NSManaged public func removeFromLoggedWorkouts(_ values: NSSet)

}
