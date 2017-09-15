//
//  Warning+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 14/09/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreData


extension Warning {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Warning> {
        return NSFetchRequest<Warning>(entityName: "Warning")
    }

    @NSManaged public var dateMade: NSDate?
    @NSManaged public var message: String?

}
