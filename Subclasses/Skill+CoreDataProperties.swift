//
//  Skill+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 02/05/2025.
//
//

import Foundation
import CoreData


extension Skill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skill> {
        return NSFetchRequest<Skill>(entityName: "Skill")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInExercises: Exercise?
    @NSManaged public var mostRecentUse: WorkoutLog?

}
