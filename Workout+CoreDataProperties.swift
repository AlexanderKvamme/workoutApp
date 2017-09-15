//
//  Workout+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 14/09/2017.
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
    @NSManaged public var exercises: NSOrderedSet?
    @NSManaged public var loggedWorkouts: NSSet?
    @NSManaged public var muscleUsed: Muscle?
    @NSManaged public var workoutStyle: WorkoutStyle?
    @NSManaged public var latestPerformence: WorkoutLog?

}

// MARK: Generated accessors for exercises
extension Workout {

    @objc(insertObject:inExercisesAtIndex:)
    @NSManaged public func insertIntoExercises(_ value: Exercise, at idx: Int)

    @objc(removeObjectFromExercisesAtIndex:)
    @NSManaged public func removeFromExercises(at idx: Int)

    @objc(insertExercises:atIndexes:)
    @NSManaged public func insertIntoExercises(_ values: [Exercise], at indexes: NSIndexSet)

    @objc(removeExercisesAtIndexes:)
    @NSManaged public func removeFromExercises(at indexes: NSIndexSet)

    @objc(replaceObjectInExercisesAtIndex:withObject:)
    @NSManaged public func replaceExercises(at idx: Int, with value: Exercise)

    @objc(replaceExercisesAtIndexes:withExercises:)
    @NSManaged public func replaceExercises(at indexes: NSIndexSet, with values: [Exercise])

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSOrderedSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSOrderedSet)

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
