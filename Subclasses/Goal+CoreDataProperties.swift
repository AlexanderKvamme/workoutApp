//
//  Goal+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 02/05/2025.
//
//

import Foundation
import CoreData


extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var dateMade: Date?
    @NSManaged public var text: String?

}
