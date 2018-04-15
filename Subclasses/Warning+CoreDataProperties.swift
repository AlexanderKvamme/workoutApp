//
//  Warning+CoreDataProperties.swift
//  workoutApp
//
//  Created by Alexander K on 15/04/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//
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
