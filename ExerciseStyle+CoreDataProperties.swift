//
//  ExerciseStyle+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/07/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension ExerciseStyle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseStyle> {
        return NSFetchRequest<ExerciseStyle>(entityName: "ExerciseStyle")
    }

    @NSManaged public var name: String?
    @NSManaged public var usedInExercises: Exercise?

}
