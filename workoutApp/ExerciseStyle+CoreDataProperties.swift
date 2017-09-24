//
//  ExerciseStyle+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 24/09/2017.
//
//

import Foundation
import CoreData


extension ExerciseStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseStyle> {
        return NSFetchRequest<ExerciseStyle>(entityName: "ExerciseStyle")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInExercises: NSSet?

}

// MARK: Generated accessors for usedInExercises
extension ExerciseStyle {

    @objc(addUsedInExercisesObject:)
    @NSManaged public func addToUsedInExercises(_ value: Exercise)

    @objc(removeUsedInExercisesObject:)
    @NSManaged public func removeFromUsedInExercises(_ value: Exercise)

    @objc(addUsedInExercises:)
    @NSManaged public func addToUsedInExercises(_ values: NSSet)

    @objc(removeUsedInExercises:)
    @NSManaged public func removeFromUsedInExercises(_ values: NSSet)

}
