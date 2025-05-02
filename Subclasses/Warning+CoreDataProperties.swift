//
//  Warning+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 02/05/2025.
//
//

import Foundation
import CoreData


extension Warning {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Warning> {
        return NSFetchRequest<Warning>(entityName: "Warning")
    }

    @NSManaged public var dateMade: Date?
    @NSManaged public var message: String?

}
