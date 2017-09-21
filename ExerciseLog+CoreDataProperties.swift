//
//  ExerciseLog+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 19/09/2017.
//
//

import Foundation
import CoreData


extension ExerciseLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseLog> {
        return NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")
    }

    @NSManaged public var datePerformed: NSDate?
    @NSManaged public var exerciseDesign: Exercise?
    @NSManaged public var lifts: NSSet?
    @NSManaged public var usedIn: WorkoutLog?

}

// MARK: Generated accessors for lifts
extension ExerciseLog {

    @objc(addLiftsObject:)
    @NSManaged public func addToLifts(_ value: Lift)

    @objc(removeLiftsObject:)
    @NSManaged public func removeFromLifts(_ value: Lift)

    @objc(addLifts:)
    @NSManaged public func addToLifts(_ values: NSSet)

    @objc(removeLifts:)
    @NSManaged public func removeFromLifts(_ values: NSSet)

}
