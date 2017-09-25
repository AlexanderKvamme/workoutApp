//
//  Lift+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 25/09/2017.
//
//

import Foundation
import CoreData


extension Lift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lift> {
        return NSFetchRequest<Lift>(entityName: "Lift")
    }

    @NSManaged public var datePerformed: NSDate?
    @NSManaged public var hasBeenPerformed: Bool
    @NSManaged public var reps: Int16
    @NSManaged public var time: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var owner: ExerciseLog?

}
