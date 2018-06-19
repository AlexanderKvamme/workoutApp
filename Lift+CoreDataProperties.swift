//
//  Lift+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander K on 19/06/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
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
    @NSManaged public var weight: Double
    @NSManaged public var owner: ExerciseLog?

}
