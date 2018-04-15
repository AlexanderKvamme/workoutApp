//
//  MeasurementStyle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander K on 15/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//
//

import Foundation
import CoreData


extension MeasurementStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MeasurementStyle> {
        return NSFetchRequest<MeasurementStyle>(entityName: "MeasurementStyle")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInExercises: NSSet?

}

// MARK: Generated accessors for usedInExercises
extension MeasurementStyle {

    @objc(addUsedInExercisesObject:)
    @NSManaged public func addToUsedInExercises(_ value: Exercise)

    @objc(removeUsedInExercisesObject:)
    @NSManaged public func removeFromUsedInExercises(_ value: Exercise)

    @objc(addUsedInExercises:)
    @NSManaged public func addToUsedInExercises(_ values: NSSet)

    @objc(removeUsedInExercises:)
    @NSManaged public func removeFromUsedInExercises(_ values: NSSet)

}
