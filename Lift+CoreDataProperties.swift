//
//  Lift+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Lift {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lift> {
        return NSFetchRequest<Lift>(entityName: "Lift")
    }

    @NSManaged public var datePerformed: NSDate?
    @NSManaged public var reps: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var owner: ExerciseLog?

}
