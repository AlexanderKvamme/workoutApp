//
//  WorkoutLog+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 13/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
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
    @NSManaged public var loggedExercises: NSSet?

}

// MARK: Generated accessors for loggedExercises
extension WorkoutLog {

    @objc(addLoggedExercisesObject:)
    @NSManaged public func addToLoggedExercises(_ value: ExerciseLog)

    @objc(removeLoggedExercisesObject:)
    @NSManaged public func removeFromLoggedExercises(_ value: ExerciseLog)

    @objc(addLoggedExercises:)
    @NSManaged public func addToLoggedExercises(_ values: NSSet)

    @objc(removeLoggedExercises:)
    @NSManaged public func removeFromLoggedExercises(_ values: NSSet)

}
