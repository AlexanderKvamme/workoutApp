//
//  Goal+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 16/08/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
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
