//
//  Warning+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 19/09/2017.
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
