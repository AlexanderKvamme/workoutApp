//
//  Skill+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 03/05/2025.
//
//

import Foundation
import CoreData


extension Skill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skill> {
        return NSFetchRequest<Skill>(entityName: "Skill")
    }

    @NSManaged public var name: String?
    @NSManaged public var mostRecentUse: WorkoutLog?
    @NSManaged public var usedInExercises: NSSet?

}

// MARK: Generated accessors for usedInExercises
extension Skill {

    @objc(addUsedInExercisesObject:)
    @NSManaged public func addToUsedInExercises(_ value: Exercise)

    @objc(removeUsedInExercisesObject:)
    @NSManaged public func removeFromUsedInExercises(_ value: Exercise)

    @objc(addUsedInExercises:)
    @NSManaged public func addToUsedInExercises(_ values: NSSet)

    @objc(removeUsedInExercises:)
    @NSManaged public func removeFromUsedInExercises(_ values: NSSet)

}
