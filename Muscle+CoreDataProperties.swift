//
//  Muscle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Muscle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Muscle> {
        return NSFetchRequest<Muscle>(entityName: "Muscle")
    }

    @NSManaged public var name: NSObject?
    @NSManaged public var usedInExercises: Exercise?

}
