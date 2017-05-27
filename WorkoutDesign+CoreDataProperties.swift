//
//  WorkoutDesign+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension WorkoutDesign {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDesign> {
        return NSFetchRequest<WorkoutDesign>(entityName: "WorkoutDesign")
    }

    @NSManaged public var muscle: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var exerciseDesigns: NSSet?
    @NSManaged public var loggedWorkouts: NSSet?

}

// MARK: Generated accessors for exerciseDesigns
extension WorkoutDesign {

    @objc(addExerciseDesignsObject:)
    @NSManaged public func addToExerciseDesigns(_ value: ExerciseDesign)

    @objc(removeExerciseDesignsObject:)
    @NSManaged public func removeFromExerciseDesigns(_ value: ExerciseDesign)

    @objc(addExerciseDesigns:)
    @NSManaged public func addToExerciseDesigns(_ values: NSSet)

    @objc(removeExerciseDesigns:)
    @NSManaged public func removeFromExerciseDesigns(_ values: NSSet)

}

// MARK: Generated accessors for loggedWorkouts
extension WorkoutDesign {

    @objc(addLoggedWorkoutsObject:)
    @NSManaged public func addToLoggedWorkouts(_ value: WorkoutLog)

    @objc(removeLoggedWorkoutsObject:)
    @NSManaged public func removeFromLoggedWorkouts(_ value: WorkoutLog)

    @objc(addLoggedWorkouts:)
    @NSManaged public func addToLoggedWorkouts(_ values: NSSet)

    @objc(removeLoggedWorkouts:)
    @NSManaged public func removeFromLoggedWorkouts(_ values: NSSet)

}
