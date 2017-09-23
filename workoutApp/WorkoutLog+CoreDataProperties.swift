//
//  WorkoutLog+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 22/09/2017.
//
//

import Foundation
import CoreData


extension WorkoutLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutLog> {
        return NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
    }

    @NSManaged public var dateEnded: NSDate?
    @NSManaged public var dateStarted: NSDate?
    @NSManaged public var design: Workout?
    @NSManaged public var loggedExercises: NSOrderedSet?

}

// MARK: Generated accessors for loggedExercises
extension WorkoutLog {

    @objc(insertObject:inLoggedExercisesAtIndex:)
    @NSManaged public func insertIntoLoggedExercises(_ value: ExerciseLog, at idx: Int)

    @objc(removeObjectFromLoggedExercisesAtIndex:)
    @NSManaged public func removeFromLoggedExercises(at idx: Int)

    @objc(insertLoggedExercises:atIndexes:)
    @NSManaged public func insertIntoLoggedExercises(_ values: [ExerciseLog], at indexes: NSIndexSet)

    @objc(removeLoggedExercisesAtIndexes:)
    @NSManaged public func removeFromLoggedExercises(at indexes: NSIndexSet)

    @objc(replaceObjectInLoggedExercisesAtIndex:withObject:)
    @NSManaged public func replaceLoggedExercises(at idx: Int, with value: ExerciseLog)

    @objc(replaceLoggedExercisesAtIndexes:withLoggedExercises:)
    @NSManaged public func replaceLoggedExercises(at indexes: NSIndexSet, with values: [ExerciseLog])

    @objc(addLoggedExercisesObject:)
    @NSManaged public func addToLoggedExercises(_ value: ExerciseLog)

    @objc(removeLoggedExercisesObject:)
    @NSManaged public func removeFromLoggedExercises(_ value: ExerciseLog)

    @objc(addLoggedExercises:)
    @NSManaged public func addToLoggedExercises(_ values: NSOrderedSet)

    @objc(removeLoggedExercises:)
    @NSManaged public func removeFromLoggedExercises(_ values: NSOrderedSet)

}
