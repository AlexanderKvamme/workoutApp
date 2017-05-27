//
//  ExerciseDesign+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 25/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension ExerciseDesign {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseDesign> {
        return NSFetchRequest<ExerciseDesign>(entityName: "ExerciseDesign")
    }

    @NSManaged public var muscle: String?
    @NSManaged public var name: String?
    @NSManaged public var plannedSets: Int16
    @NSManaged public var type: String?
    @NSManaged public var lifts: Lift?
    @NSManaged public var usedIn: NSSet?
    @NSManaged public var workouts: NSSet?

}

// MARK: Generated accessors for usedIn
extension ExerciseDesign {

    @objc(addUsedInObject:)
    @NSManaged public func addToUsedIn(_ value: ExerciseLog)

    @objc(removeUsedInObject:)
    @NSManaged public func removeFromUsedIn(_ value: ExerciseLog)

    @objc(addUsedIn:)
    @NSManaged public func addToUsedIn(_ values: NSSet)

    @objc(removeUsedIn:)
    @NSManaged public func removeFromUsedIn(_ values: NSSet)

}

// MARK: Generated accessors for workouts
extension ExerciseDesign {

    @objc(addWorkoutsObject:)
    @NSManaged public func addToWorkouts(_ value: WorkoutDesign)

    @objc(removeWorkoutsObject:)
    @NSManaged public func removeFromWorkouts(_ value: WorkoutDesign)

    @objc(addWorkouts:)
    @NSManaged public func addToWorkouts(_ values: NSSet)

    @objc(removeWorkouts:)
    @NSManaged public func removeFromWorkouts(_ values: NSSet)

}
