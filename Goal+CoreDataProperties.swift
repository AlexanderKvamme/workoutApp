//
//  Goal+CoreDataProperties.swift
//  
//
//  Created by Alexander Kvamme on 25/09/2017.
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
