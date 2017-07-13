//
//  WorkoutStyle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 13/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension WorkoutStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutStyle> {
        return NSFetchRequest<WorkoutStyle>(entityName: "WorkoutStyle")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInWorkouts: Workout?

}
