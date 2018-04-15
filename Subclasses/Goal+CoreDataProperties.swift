//
//  Goal+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander K on 15/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var dateMade: NSDate?
    @NSManaged public var text: String?

}
